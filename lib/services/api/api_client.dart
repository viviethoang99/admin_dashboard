import 'package:dio/dio.dart';
import 'package:irohasu_admin/services/api/api_result.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

import '../../env/env.dart';
import '../../feature/login/models/login.dart';
import '../../feature/posts/models/post_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) {
    return _ApiClient(dio);
  }

  factory ApiClient.create() => ApiClient(Dio()
    ..options = BaseOptions(baseUrl: Env.domain)
    ..interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      )
    ]));

  @POST('/api/login')
  Future<ApiResult<LoginResponse>> login(@Body() Login data);

  @GET('/api/posts')
  Future<ApiResult<List<PostModel>>> fetchPosts();

  @GET('/api/posts/{id}')
  Future<ApiResult<PostModel>> fetchPost(@Path('id') String id);
}
