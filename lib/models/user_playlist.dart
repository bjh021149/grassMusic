import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_playlist.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class UserPlaylist {
  @HiveField(0)
  @JsonKey(name: 'id', fromJson: _parseId)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name', defaultValue: '未知歌单')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'coverImgUrl', fromJson: _parseCoverUrl)
  final String coverImgUrl;

  @HiveField(3)
  @JsonKey(name: 'trackCount', defaultValue: 0)
  final int trackCount;

  @HiveField(4)
  @JsonKey(name: 'playCount', defaultValue: 0)
  final int playCount;

  @HiveField(5)
  @JsonKey(name: 'creator', fromJson: _parseCreatorName)
  final String creator;

  @HiveField(6)
  @JsonKey(name: 'subscribed', defaultValue: false)
  final bool subscribed;

  UserPlaylist({
    required this.id,
    required this.name,
    required this.coverImgUrl,
    required this.trackCount,
    required this.playCount,
    required this.creator,
    required this.subscribed,
  });

  // JSON 解析辅助方法
  static String _parseId(dynamic id) => id?.toString() ?? '';

  static String _parseCoverUrl(dynamic json) {
    if (json is Map) {
      return json['coverImgUrl'] ??
          json['picUrl'] ??
          json['cover']?['imgUrl']?.toString() ??
          '';
    }
    return json?.toString() ?? '';
  }

  static String _parseCreatorName(dynamic json) {
    if (json is Map) {
      return json['nickname']?.toString() ??
          json['userId']?.toString() ??
          '未知用户';
    }
    return '未知用户';
  }

  // 自动生成的工厂方法和toJson
  factory UserPlaylist.fromJson(Map<String, dynamic> json) =>
      _$UserPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlaylistToJson(this);

  // 保留copyWith方法
  UserPlaylist copyWith({
    String? id,
    String? name,
    String? coverImgUrl,
    int? trackCount,
    int? playCount,
    String? creator,
    bool? subscribed,
  }) {
    return UserPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImgUrl: coverImgUrl ?? this.coverImgUrl,
      trackCount: trackCount ?? this.trackCount,
      playCount: playCount ?? this.playCount,
      creator: creator ?? this.creator,
      subscribed: subscribed ?? this.subscribed,
    );
  }

  @override
  String toString() {
    return 'UserPlaylist{id: $id, name: $name, trackCount: $trackCount}';
  }
}
