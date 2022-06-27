//start from bottom most classes ,in our case secure credential storage
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/infrastructure/credential_storage/credential_storage.dart';
import 'package:repo_viewer/auth/infrastructure/credential_storage/secure_credentials_storage.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:repo_viewer/auth/infrastructure/oauth2_interceptor.dart';
import 'package:riverpod/riverpod.dart';

final flutterSecureStorageProvider =
    Provider((ref) => const FlutterSecureStorage());

final dioForAuthProvider = Provider(
  (ref) => Dio(),
);

final oAuthInterceptorProvider = Provider(
  (ref) => OAuth2Interceptor(
    ref.watch(githubAuthenticatorProvider),
    ref.watch(authNotifierProvider.notifier),
    ref.watch(dioForAuthProvider),
  ),
);

//not the concrete class but the abstract class
final credentialsStorageProvider = Provider<CredentialsStorage>(
    (ref) => SecureCredentialsStorage(ref.watch(flutterSecureStorageProvider)));

final githubAuthenticatorProvider = Provider(
  (ref) => GithubAuthenticator(
    ref.watch(credentialsStorageProvider),
    ref.watch(dioForAuthProvider),
  ),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(githubAuthenticatorProvider)),
);
