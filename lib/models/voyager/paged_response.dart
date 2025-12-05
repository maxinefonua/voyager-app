class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool first;
  final int numberOfElements;

  PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
    required this.numberOfElements,
  });

  // JSON serialization
  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT, // Change parameter type
  ) {
    return PagedResponse<T>(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      last: json['last'] as bool,
      first: json['first'] as bool,
      numberOfElements: json['numberOfElements'] as int,
    );
  }
}
