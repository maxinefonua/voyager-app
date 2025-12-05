import 'package:voyager/models/path/path_detailed.dart';

class SearchResponse {
  final List<PathDetailed> content;
  final String status;
  final bool hasMore;
  final int totalFound;
  final int size;

  SearchResponse({
    required this.content,
    required this.status,
    required this.hasMore,
    required this.totalFound,
    required this.size,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      content: ((json['content']) as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => PathDetailed.fromJson(item))
          .toList(),
      status: json['status'],
      hasMore: json['hasMore'] as bool,
      totalFound: json['totalFound'] as int,
      size: json['size'] as int,
    );
  }
}
