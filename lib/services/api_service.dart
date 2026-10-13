import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../models/student_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://buiphukhuyen.io.vn';
  static const Duration timeoutDuration = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Kiểm tra thông tin sinh viên theo MSSV
  Future<StudentModel> checkStudent(String mssv) async {
    final uri = Uri.parse('$baseUrl/api/student/check')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client.get(uri).timeout(timeoutDuration);
      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          if (data['registered'] == false) {
            throw ApiException(
              data['message']?.toString() ?? 'MSSV chưa được cấp quyền',
              response.statusCode,
            );
          }
          return StudentModel.fromJson(data);
        }
        throw ApiException('Định dạng dữ liệu trả về không hợp lệ');
      } else {
        _handleError(response, data);
        throw ApiException('Không thể kiểm tra sinh viên', response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi kết nối máy chủ: $e');
    }
  }

  /// Lấy danh sách tất cả bài viết theo MSSV
  Future<List<PostModel>> getPosts(String mssv) async {
    final uri = Uri.parse('$baseUrl/api/post')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client.get(uri).timeout(timeoutDuration);
      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is List) {
          return data
              .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        _handleError(response, data);
        return [];
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tải danh sách bài viết: $e');
    }
  }

  /// Lấy chi tiết một bài viết theo ID và MSSV
  Future<PostModel> getPostDetail(String mssv, int id) async {
    final uri = Uri.parse('$baseUrl/api/post/$id')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client.get(uri).timeout(timeoutDuration);
      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          return PostModel.fromJson(data);
        }
        throw ApiException('Dữ liệu bài viết không hợp lệ');
      } else {
        _handleError(response, data);
        throw ApiException('Không tìm thấy bài viết', response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi xem chi tiết bài viết: $e');
    }
  }

  /// Tạo mới một bài viết
  Future<PostModel> createPost(String mssv, String title, String body) async {
    final uri = Uri.parse('$baseUrl/api/post')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'title': title.trim(), 'body': body.trim()}),
          )
          .timeout(timeoutDuration);

      final data = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          return PostModel.fromJson(data);
        }
        throw ApiException('Không thể xử lý dữ liệu trả về sau khi tạo');
      } else {
        _handleError(response, data);
        throw ApiException('Tạo bài viết thất bại', response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi tạo bài viết mới: $e');
    }
  }

  /// Cập nhật bài viết theo ID
  Future<PostModel> updatePost(
      String mssv, int id, String title, String body) async {
    final uri = Uri.parse('$baseUrl/api/post/$id')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client
          .put(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'title': title.trim(), 'body': body.trim()}),
          )
          .timeout(timeoutDuration);

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          return PostModel.fromJson(data);
        }
        throw ApiException('Không thể xử lý phản hồi cập nhật');
      } else {
        _handleError(response, data);
        throw ApiException('Cập nhật thất bại', response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi cập nhật bài viết: $e');
    }
  }

  /// Xóa một bài viết theo ID
  Future<bool> deletePost(String mssv, int id) async {
    final uri = Uri.parse('$baseUrl/api/post/$id')
        .replace(queryParameters: {'username': mssv.trim()});

    try {
      final response = await _client.delete(uri).timeout(timeoutDuration);
      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return true;
      } else {
        _handleError(response, data);
        return false;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Lỗi khi xóa bài viết: $e');
    }
  }

  dynamic _decodeResponse(http.Response response) {
    try {
      final decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(decoded);
    } catch (_) {
      return {'raw': response.body};
    }
  }

  void _handleError(http.Response response, dynamic data) {
    String message = 'Đã có lỗi xảy ra (${response.statusCode})';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'].toString();
    } else if (response.statusCode == 400) {
      message = 'Yêu cầu không hợp lệ hoặc thiếu thông tin';
    } else if (response.statusCode == 403) {
      message = 'Bạn đã vượt quá hạn mức cho phép hoặc chưa được cấp quyền';
    } else if (response.statusCode == 404) {
      message = 'Không tìm thấy dữ liệu yêu cầu';
    } else if (response.statusCode == 429) {
      message = 'Bạn đã gọi API quá nhanh. Vui lòng thử lại sau vài giây';
    } else if (response.statusCode >= 500) {
      message = 'Lỗi máy chủ hệ thống (${response.statusCode})';
    }
    throw ApiException(message, response.statusCode);
  }
}
