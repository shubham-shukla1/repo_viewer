import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/infrastrcture/sembast_databse.dart';

final sembastProvider = Provider(
  (ref) => SembastDatabase(),
);

final dioProvider = Provider(
  (ref) => Dio(),
);
