import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@Freezed(
  copyWith: true,
  equal: true,
)
class PostModel with _$PostModel {
  const factory PostModel({
    String? id,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    String? content,
    String? img,
    String? endponit,
    List<String>? tags,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => toJson();
}
