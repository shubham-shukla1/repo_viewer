import 'dart:io';

import 'package:flutter/material.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizationPage extends StatefulWidget {
 final Uri authorizationUrl;
  final void Function(Uri redirectUrl) onAuthorizationCodeRedirectAttempt;

  const AuthorizationPage({
    Key? key,
    required this.authorizationUrl,
    required this.onAuthorizationCodeRedirectAttempt,
  }) : super(key: key);

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
 
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          //webview does not work with Uri , it work with string
          initialUrl: widget.authorizationUrl.toString(),
          onWebViewCreated: (controller) {
            //Clears all caches used by the [WebView].
            controller.clearCache();
            //Returns true if cookies were present before clearing, else false.
            CookieManager().clearCookies();
          },
          //A delegate function that decides how to handle navigation actions.
          navigationDelegate: (navReq) {
            if (navReq.url
                .startsWith(GithubAuthenticator.redirectUrl.toString())) {
              widget.onAuthorizationCodeRedirectAttempt(Uri.parse(navReq.url));
              //prevent navigation,if redirect url
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
