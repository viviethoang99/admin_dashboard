import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/api/api_service.dart';
import '../model/tag_model.dart';

part 'tags.g.dart';

@riverpod 
class Tags extends _$Tags {
  static const int itemsPerPage = 10;

  @override
  Future<List<TagModel>> build() async {
    final apiResult = await ref.watch(apiServiceProvider).fetchTags();

    if (apiResult.data.isNotEmpty) {
      return apiResult.data;
    } else {
      throw Exception('Failed to fetch tags');
    }
  }
}