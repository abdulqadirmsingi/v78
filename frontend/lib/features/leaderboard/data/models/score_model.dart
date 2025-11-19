import 'package:json_annotation/json_annotation.dart';

part 'score_model.g.dart';

@JsonSerializable()
class ScoreModel {
  final String id;
  final String name;
  final int score;
  final int rank;
  @JsonKey(name: 'created_at')
  final String createdAt;

  ScoreModel({
    required this.id,
    required this.name,
    required this.score,
    required this.rank,
    required this.createdAt,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreModelToJson(this);
}

@JsonSerializable()
class LeaderboardResponse {
  final List<ScoreModel> leaderboard;
  final int total;

  LeaderboardResponse({
    required this.leaderboard,
    required this.total,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardResponseToJson(this);
}

@JsonSerializable()
class SubmitScoreRequest {
  final String name;
  final int score;

  SubmitScoreRequest({
    required this.name,
    required this.score,
  });

  Map<String, dynamic> toJson() => _$SubmitScoreRequestToJson(this);
}

