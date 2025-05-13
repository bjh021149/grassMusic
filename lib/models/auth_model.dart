import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@HiveType(typeId: 1) // 分配唯一typeId
@JsonSerializable()
class LoginResult {
  @HiveField(0)
  final int loginType;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final int effectTime;

  @HiveField(3)
  final int code;

  @HiveField(4)
  final Account account;

  @HiveField(5)
  final String token;

  @HiveField(6)
  final Profile profile;

  @HiveField(7)
  final List<Binding> bindings;

  @HiveField(8)
  final String cookie;

  LoginResult({
    required this.loginType,
    required this.clientId,
    required this.effectTime,
    required this.code,
    required this.account,
    required this.token,
    required this.profile,
    required this.bindings,
    required this.cookie,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}

@HiveType(typeId: 2)
@JsonSerializable()
class Account {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final int type;

  @HiveField(3)
  final int status;

  @HiveField(4)
  final int whitelistAuthority;

  @HiveField(5)
  final int createTime;

  @HiveField(6)
  final String salt;

  @HiveField(7)
  final int tokenVersion;

  @HiveField(8)
  final int ban;

  @HiveField(9)
  final int baoyueVersion;

  @HiveField(10)
  final int donateVersion;

  @HiveField(11)
  final int vipType;

  @HiveField(12)
  final int viptypeVersion;

  @HiveField(13)
  final bool anonimousUser;

  @HiveField(14)
  final bool uninitialized;

  Account({
    required this.id,
    required this.userName,
    required this.type,
    required this.status,
    required this.whitelistAuthority,
    required this.createTime,
    required this.salt,
    required this.tokenVersion,
    required this.ban,
    required this.baoyueVersion,
    required this.donateVersion,
    required this.vipType,
    required this.viptypeVersion,
    required this.anonimousUser,
    required this.uninitialized,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable()
class Profile {
  @HiveField(0)
  final int userType;

  @HiveField(1)
  final String avatarUrl;

  @HiveField(2)
  final int vipType;

  @HiveField(3)
  final int authStatus;

  @HiveField(4)
  final int djStatus;

  @HiveField(5)
  final String detailDescription;

  @HiveField(6)
  final Map<String, dynamic> experts;

  @HiveField(7)
  final dynamic expertTags;

  @HiveField(8)
  final int accountStatus;

  @HiveField(9)
  final String nickname;

  @HiveField(10)
  final int birthday;

  @HiveField(11)
  final int gender;

  @HiveField(12)
  final int province;

  @HiveField(13)
  final int city;

  @HiveField(14)
  final int avatarImgId;

  @HiveField(15)
  final int backgroundImgId;

  @HiveField(16)
  final bool defaultAvatar;

  @HiveField(17)
  final bool mutual;

  @HiveField(18)
  final dynamic remarkName;

  @HiveField(19)
  final bool followed;

  @HiveField(20)
  final String backgroundUrl;

  @HiveField(21)
  final String avatarImgIdStr;

  @HiveField(22)
  final String backgroundImgIdStr;

  @HiveField(23)
  final String description;

  @HiveField(24)
  final int userId;

  @HiveField(25)
  final String signature;

  @HiveField(26)
  final int authority;

  @HiveField(27)
  final int followeds;

  @HiveField(28)
  final int follows;

  @HiveField(29)
  final int eventCount;

  @HiveField(30)
  final dynamic avatarDetail;

  @HiveField(31)
  final int playlistCount;

  @HiveField(32)
  final int playlistBeSubscribedCount;

  Profile({
    required this.userType,
    required this.avatarUrl,
    required this.vipType,
    required this.authStatus,
    required this.djStatus,
    required this.detailDescription,
    required this.experts,
    required this.expertTags,
    required this.accountStatus,
    required this.nickname,
    required this.birthday,
    required this.gender,
    required this.province,
    required this.city,
    required this.avatarImgId,
    required this.backgroundImgId,
    required this.defaultAvatar,
    required this.mutual,
    required this.remarkName,
    required this.followed,
    required this.backgroundUrl,
    required this.avatarImgIdStr,
    required this.backgroundImgIdStr,
    required this.description,
    required this.userId,
    required this.signature,
    required this.authority,
    required this.followeds,
    required this.follows,
    required this.eventCount,
    required this.avatarDetail,
    required this.playlistCount,
    required this.playlistBeSubscribedCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@HiveType(typeId: 4)
@JsonSerializable()
class Binding {
  @HiveField(0)
  final int bindingTime;

  @HiveField(1)
  final int refreshTime;

  @HiveField(2)
  final Map<String, dynamic> tokenJsonStr;

  @HiveField(3)
  final int expiresIn;

  @HiveField(4)
  final String url;

  @HiveField(5)
  final bool expired;

  @HiveField(6)
  final int userId;

  @HiveField(7)
  final int id;

  @HiveField(8)
  final int type;

  Binding({
    required this.bindingTime,
    required this.refreshTime,
    required this.tokenJsonStr,
    required this.expiresIn,
    required this.url,
    required this.expired,
    required this.userId,
    required this.id,
    required this.type,
  });

  factory Binding.fromJson(Map<String, dynamic> json) =>
      _$BindingFromJson(json);

  Map<String, dynamic> toJson() => _$BindingToJson(this);
}
