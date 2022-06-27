//use code snippet funion and use ptf for part and the run build runner watch

import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_failure.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const AuthFailure._();
  const factory AuthFailure.server([String? message]) = _Server;
  const factory AuthFailure.storage() = _Storage;
}
