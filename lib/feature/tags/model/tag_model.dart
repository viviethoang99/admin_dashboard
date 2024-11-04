import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@Freezed(toJson: true)
class TagModel with _$TagModel {
  const factory TagModel({
    int? id,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    int? count,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}
