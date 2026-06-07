import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/course_api_model.dart';

class CourseRepository {
  final DioClient client;
  CourseRepository(this.client);

  Future<List<CourseApiModel>> getCourses({String? category}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.courses,
        queryParameters: {if (category != null) 'category': category},
      );
      final data = (res.data['data']['courses'] as List? ?? []);
      return data.map((j) => CourseApiModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) { throw client.toApiException(e); }
  }

  Future<CourseApiModel> getCourse(String id) async {
    try {
      final res = await client.dio.get('${ApiConstants.courses}/$id');
      return CourseApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) { throw client.toApiException(e); }
  }

  Future<List<CourseApiModel>> getAdminCourses({int page = 1, String? search}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.coursesAdmin,
        queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search},
      );
      final data = (res.data['data']['courses'] as List? ?? []);
      return data.map((j) => CourseApiModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) { throw client.toApiException(e); }
  }

  Future<CourseApiModel> createCourse(Map<String, dynamic> data) async {
    try {
      final res = await client.dio.post(ApiConstants.courses, data: data);
      return CourseApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) { throw client.toApiException(e); }
  }

  Future<CourseApiModel> updateCourse(String id, Map<String, dynamic> data) async {
    try {
      final res = await client.dio.put('${ApiConstants.courses}/$id', data: data);
      return CourseApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) { throw client.toApiException(e); }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await client.dio.delete('${ApiConstants.courses}/$id');
    } catch (e) { throw client.toApiException(e); }
  }
}
