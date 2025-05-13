// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPlaylistAdapter extends TypeAdapter<UserPlaylist> {
  @override
  final int typeId = 0;

  @override
  UserPlaylist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPlaylist(
      id: fields[0] as String,
      name: fields[1] as String,
      coverImgUrl: fields[2] as String,
      trackCount: fields[3] as int,
      playCount: fields[4] as int,
      creator: fields[5] as String,
      subscribed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPlaylist obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.coverImgUrl)
      ..writeByte(3)
      ..write(obj.trackCount)
      ..writeByte(4)
      ..write(obj.playCount)
      ..writeByte(5)
      ..write(obj.creator)
      ..writeByte(6)
      ..write(obj.subscribed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPlaylist _$UserPlaylistFromJson(Map<String, dynamic> json) => UserPlaylist(
      id: UserPlaylist._parseId(json['id']),
      name: json['name'] as String? ?? '未知歌单',
      coverImgUrl: UserPlaylist._parseCoverUrl(json['coverImgUrl']),
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      creator: UserPlaylist._parseCreatorName(json['creator']),
      subscribed: json['subscribed'] as bool? ?? false,
    );

Map<String, dynamic> _$UserPlaylistToJson(UserPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coverImgUrl': instance.coverImgUrl,
      'trackCount': instance.trackCount,
      'playCount': instance.playCount,
      'creator': instance.creator,
      'subscribed': instance.subscribed,
    };
