import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/core/shared/providers.dart';

//some of initialization steps is async so we are using future provider
//we always provide object but in async case it is different

final initializationProvider = FutureProvider<Unit>((ref) async {
// we do not want this init provider to run multiple times,whenever these change but it is not going to change

  await ref.read(sembastProvider).init();
//modifying dio base option will be included in modifying base class or super ,
// it will be included in all request involving dio
  ref.read(dioProvider)
    ..options = BaseOptions(headers: {
      'Accept':'application/vnd.github.v3.html+json'
    },
    //we are showing 304 as not in error block but in try block 
    //so need to validate the status as it might cause error
    validateStatus:(status)=> status !=null && status >=200 && status <400 )
    ..interceptors.add(ref.read(oAuthInterceptorProvider));
  final authNotifier = ref.read(authNotifierProvider.notifier);

  await authNotifier.checkAndUpdateAuthStatus();
  return unit;
});

class AppWidget extends ConsumerWidget {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {});

    ref.listen<AuthState>(authNotifierProvider,
        (AuthState? prev, AuthState? state) {
      state?.maybeWhen(
          orElse: () {},
          authenticated: () {
            appRouter.pushAndPopUntil(const StarredReposRoute(),
                predicate: ((route) => false));
          },
          unauthenticated: () {
            appRouter.pushAndPopUntil(const SignInRoute(),
                predicate: ((route) => false));
          });
    });

    return MaterialApp.router(
      title: 'Repo Viewer',
      routeInformationParser: appRouter.defaultRouteParser(),
      routerDelegate: appRouter.delegate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
