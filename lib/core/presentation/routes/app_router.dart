// @CupertinoAutoRouter
// @AdaptiveAutoRouter
// @CustomAutoRouter
import 'package:auto_route/annotations.dart';
import 'package:repo_viewer/auth/presentation/authorization_page.dart';
import 'package:repo_viewer/splash/presentation/splash_page.dart';

import '../../../auth/presentation/sign_in_page.dart';
import '../../../github/repos/starred_repos/presentation/presentation/starred_repos_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashPage, initial: true),
    MaterialRoute(page: SignInPage, path: '/sign-in'),
    MaterialRoute(page: StarredReposPage, path: '/starred'),
    MaterialRoute(page: AuthorizationPage, path: '/auth'),

  ],
)
// extend the generated private router
class $AppRouter {}