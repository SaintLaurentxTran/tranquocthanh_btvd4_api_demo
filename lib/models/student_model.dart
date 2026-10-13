class StudentModel {
  final String mssv;
  final String fullName;
  final String? className;
  final bool isActive;
  final int maxPosts;
  final int dailyRequestLimit;
  final int requestsToday;
  final int postsCount;

  StudentModel({
    required this.mssv,
    required this.fullName,
    this.className,
    this.isActive = true,
    this.maxPosts = 20,
    this.dailyRequestLimit = 500,
    this.requestsToday = 0,
    this.postsCount = 0,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final studentData =
        json.containsKey('student') && json['student'] is Map<String, dynamic>
            ? json['student'] as Map<String, dynamic>
            : json;

    return StudentModel(
      mssv: studentData['mssv']?.toString() ?? '',
      fullName: studentData['full_name']?.toString() ?? 'Chưa rõ',
      className: studentData['class_name']?.toString(),
      isActive: studentData['is_active'] == true,
      maxPosts: (studentData['max_posts'] as num?)?.toInt() ?? 20,
      dailyRequestLimit:
          (studentData['daily_request_limit'] as num?)?.toInt() ?? 500,
      requestsToday: (studentData['requests_today'] as num?)?.toInt() ?? 0,
      postsCount: (studentData['posts_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mssv': mssv,
      'full_name': fullName,
      'class_name': className,
      'is_active': isActive,
      'max_posts': maxPosts,
      'daily_request_limit': dailyRequestLimit,
      'requests_today': requestsToday,
      'posts_count': postsCount,
    };
  }

  StudentModel copyWith({
    String? mssv,
    String? fullName,
    String? className,
    bool? isActive,
    int? maxPosts,
    int? dailyRequestLimit,
    int? requestsToday,
    int? postsCount,
  }) {
    return StudentModel(
      mssv: mssv ?? this.mssv,
      fullName: fullName ?? this.fullName,
      className: className ?? this.className,
      isActive: isActive ?? this.isActive,
      maxPosts: maxPosts ?? this.maxPosts,
      dailyRequestLimit: dailyRequestLimit ?? this.dailyRequestLimit,
      requestsToday: requestsToday ?? this.requestsToday,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}
