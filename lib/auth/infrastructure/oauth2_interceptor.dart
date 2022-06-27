import 'package:dio/dio.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';

//Dio instance may have interceptor(s) by which you can intercept requests/responses/errors before they are handled by then or catchError
class OAuth2Interceptor extends Interceptor {
  final GithubAuthenticator _authenticator;
  final AuthNotifier _authNotifier;
  final Dio _dio;

  OAuth2Interceptor(this._authenticator, this._authNotifier, this._dio);
  //this modified interceptor is The callback will be executed before the request is initiated.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final credential = await _authenticator.getSignedInCredentials();
    //pass modified options to the request which we have just intercepted by calling
    // options.headers return type void ,cascading operators by accessing headers, headers object
    //// now modified option will be Request option
    final modifiedOptions = options
      ..headers.addAll(credential == null
          ? {}
          : {'Authorization': 'bearer ${credential.accessToken}'});
    handler.next(modifiedOptions);
  }

  //Intercept on error ,it will intercept every possible dio error
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    //access token might expire , unauthorized response will happen,solution either refresh access token
    //since we cannot refresh  in github, simply signOut
    //separate check for not  null, if (err.requestOptions != null && err.response?.statusCode == 401),so no need to check for null again

    final errorResponse = err.response;
    if (errorResponse != null && errorResponse.statusCode == 401) {
      final credential = await _authenticator.getSignedInCredentials();
      //cannot revoke access token if it is already invalid as in signout method,no sense in doing signout
      credential != null && credential.canRefresh
          ? await _authenticator.refresh(credential)
          : await _authenticator.clearCredentialsStorage();
      //if clear storage then check if it is authenticated or not, for navigation
      await _authNotifier.checkAndUpdateAuthStatus();
      final refreshedCredentials =
          await _authenticator.getSignedInCredentials();
      if (refreshedCredentials != null) {
        handler.resolve(
          await _dio.fetch(
            errorResponse.requestOptions
              ..headers['Authorization'] = 'bearer $refreshedCredentials',
          ),
        );
      }
    } else {
      handler.next(err);
    }

    super.onError(err, handler);
  }
}
