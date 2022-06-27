//abstract because this class will be only used as the superclass for individual starred and searched remote se service
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastrcture/networ_exception.dart';
import 'package:repo_viewer/core/infrastrcture/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/core/infrastrcture/dio_extension.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';

abstract class ReposRemoteService {
  //remote services do not hold state in them
  //also repositories not hold state
  //class depend on dio
  final Dio _dio;
  final GithubHeadersCache _githubHeadersCache;
//inside infrastructure

  ReposRemoteService(this._dio, this._githubHeadersCache);

//get starred repos and searched page from github api
  Future<RemoteResponse<List<GithubRepoDTO>>> getPage({
    required Uri requestUri,
    required List<dynamic> Function(dynamic json) jsonDataSelector,
  }) async {
    ///no need to include page parameter because we will provide in the sub class

    //headers come from previous response
    final previousHeaders = await _githubHeadersCache.getHeaders(requestUri);

    try {
      final response = await _dio.getUri(requestUri,
          options: Options(headers: {
            //comment these hardcoded token and header , coz token is added in the auth interceptor
            //and accept header is added in base option , centralized way to add all headers
            // 'Authorization': 'bearer $token',
            // 'Accept': acceptHeader,
            'If-None-Match': previousHeaders?.eTag ?? ""
          }));
      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
            maxPage: previousHeaders?.link?.maxPage ?? 0);
      }

      if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        await _githubHeadersCache.saveHeaders(requestUri, headers);
        //for every element of list e call github repo dto from json and pass e of list
        final convertData = jsonDataSelector(response.data)
            .map((e) => GithubRepoDTO.fromJson(e as Map<String, dynamic>))
            .toList();
        return RemoteResponse.withNewData(convertData,
            //maxPage will be at least 1
            maxPage: headers.link?.maxPage ?? 1);
      } else {
        //most probably never ever run, but for 201, 204 it will run
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        //no connection we are always going to show the cached data
        //if no previousHeaders then maxPage will be zero
        return const RemoteResponse.noConnection();
      } else if (e.response != null) {
        //not all dio error comes from Dio thats why response , make nullable like Connection Error which is not from dio but device

        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
    //options for headers, two hears token and headers
  }
}
