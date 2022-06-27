//operation with dio , so its infrastructure related thing also can be used from anywhere
import 'dart:io';

import 'package:dio/dio.dart';

extension DioErrorX on DioError {
  bool get isNoConnectionError {
    return type == DioErrorType.other && error is SocketException;
  }
}
