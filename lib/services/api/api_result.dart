import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResult<T> {
  final T data;
  @JsonKey(defaultValue: '')
  final String? error;

  const ApiResult({required this.data, this.error});

  factory ApiResult.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$ApiResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => _$ApiResultToJson(this, toJsonT);

  @override
  String toString() => 'ApiResult(data: $data, error: $error)';
}
