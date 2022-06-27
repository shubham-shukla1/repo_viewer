import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:repo_viewer/auth/domain/auth_failure.dart';
import 'package:repo_viewer/auth/infrastructure/credential_storage/credential_storage.dart';
import 'package:http/http.dart' as http;
import 'package:repo_viewer/core/infrastrcture/dio_extension.dart';
import 'package:repo_viewer/core/shared/encoders.dart';

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    //as in github doc
    request.headers['Accept'] = "application/json";
    //pass this modified request object to default http client
    return httpClient.send(request);
  }
}

// Follow single responsibility principle not going to add bunch of code into a single instead multiple classes to break code
class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;

  GithubAuthenticator(this._credentialsStorage, this._dio);
  static const clientId = 'cf9286cf5b6659822703';
  //do not paste client secret like this ,then anybody can see it which is wrong
  static const clientSecret = '1d1b7dc956c8c1bedd8f25b1a550ffe38c135b37';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndpoint =
      Uri.parse("https://github.com/login/oauth/authorize");
  static final revocationEndpoint =
      Uri.parse('https://api.github.com/applications/$clientId/token');
  static final tokenEndpoint =
      Uri.parse("https://github.com/login/oauth/access_token");

  static final redirectUrl = Uri.parse("http://localhost:3000/callback");

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      //refresh token
      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          final failureOrCredentials = await refresh(storedCredentials);
          failureOrCredentials.fold((l) => null, (r) => r);
        }
      }
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);
  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret,
        //github will respond with  json response instead of the  Url En Coded response
        // and ouath 2 will have no problem processing with it
        httpClient: GithubOAuthHttpClient());
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant codeGrant) {
    return codeGrant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  //helper method for auth response
  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
      AuthorizationCodeGrant grant
//query param which is going to be present in the redirect url,it contains auth code
      ,
      Map<String, String> queryParameter) async {
//handle exceptions because method handleAuthorizationResponse can fail, Throws [FormatError] if [parameters] is invalid according to the OAuth2 spec or if the authorization server otherwise provides invalid responses.
//If state was passed to [getAuthorizationUrl], this will throw a [FormatError] if the state parameter doesn't match the original value.
//Throws [AuthorizationException] if the authorization fails.
    try {
//Unit is same thing as void , as we need to transform exception into failure,thats why unit
//http client simply use ,we use dio
      final httpClient =
          await grant.handleAuthorizationResponse(queryParameter);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      //this has to do with server
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}:${e.description}'));
    } on PlatformException {
      //platform exc comes from storage
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      final accessToken = await _credentialsStorage
          .read()
          .then((credentials) => credentials?.accessToken);

      final usernameAndPassword =
          stringToBase64.encode('$clientId:$clientSecret');

      try {
        await _dio.deleteUri(
          revocationEndpoint,
          data: {
            'access_token': accessToken,
          },
          options: Options(
            headers: {
              'Authorization': 'basic $usernameAndPassword',
            },
          ),
        );
      } on DioError catch (e) {
        if (e.isNoConnectionError) {
          // Ignoring
        } else {
          rethrow;
        }
      }
      return clearCredentialsStorage();
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> clearCredentialsStorage() async {
    try {
      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Credentials>> refresh(
      Credentials credentials) async {
    //This throws an [ArgumentError] if [secret] is passed without [identifier], a [StateError]
    // if these credentials can't be refreshed, an [AuthorizationException]
    //if refreshing the credentials fails, or a [FormatError] if the authorization server returns invalid responses.

//Exception are generally non breaking and error are breaking there is no way to recover from them, however dio error is recoverd
//do not catch error
    try {} on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      //e=exception object caught is not const
      return left(AuthFailure.server('${e.error}:${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
    final refreshedCredentials = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOAuthHttpClient());
    await _credentialsStorage.save(refreshedCredentials);
    return right(refreshedCredentials);
  }
}
