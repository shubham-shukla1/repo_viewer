import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'github_headers.freezed.dart';
part 'github_headers.g.dart';
@freezed
class GithubHeaders with _$GithubHeaders {
  const GithubHeaders._();
  const factory GithubHeaders({
    String? eTag,
    PaginationLink? link,
  }) = _GithubHeaders;
  factory GithubHeaders.parse(Response response) {
    final link = response.headers.map['Link']?[0];
    return GithubHeaders(
        eTag: response.headers.map['ETag']?[0],
        link: link == null
            ? null
            : PaginationLink.parse(link.split(','),
                requestUrl: response.requestOptions.uri.toString()));
  }

  factory GithubHeaders.fromJson(Map<String, dynamic> json) => _$GithubHeadersFromJson(json);
}

@freezed
class PaginationLink with _$PaginationLink {
  const PaginationLink._();
  const factory PaginationLink({required int maxPage}) = _PaginationLink;

//values from headers which is of same type as values
  factory PaginationLink.parse(List<String> values,
      //values List not always contain next and last url
      {required String requestUrl}) {
    return PaginationLink(
        maxPage: _extractPageNo(values.firstWhere(
            (e) => e.contains('rel="last"'),
            orElse: () => requestUrl)));
  }
  //since we need to call extract page no inside of factory
  //it needs to be static, otherwise it would be an instance method
  //while we are constructing we can not call instance method
  static int _extractPageNo(String value) {
    //value is 2nd part of link header github
    final uriString = RegExp(
            r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')
        .stringMatch(value);

    return int.parse(Uri.parse(uriString!).queryParameters['page']!);
  }
  factory PaginationLink.fromJson(Map<String, dynamic> json) => _$PaginationLinkFromJson(json);
}
