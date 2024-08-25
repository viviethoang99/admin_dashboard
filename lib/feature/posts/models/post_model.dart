import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    String? id,
    int? status,
    String? createdAt,
    String? updatedAt,
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
