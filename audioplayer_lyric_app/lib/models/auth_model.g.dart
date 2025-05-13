// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginResultAdapter extends TypeAdapter<LoginResult> {
  @override
  final int typeId = 1;

  @override
  LoginResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginResult(
      loginType: fields[0] as int,
      clientId: fields[1] as String,
      effectTime: fields[2] as int,
      code: fields[3] as int,
      account: fields[4] as Account,
      token: fields[5] as String,
      profile: fields[6] as Profile,
      bindings: (fields[7] as List).cast<Binding>(),
      cookie: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoginResult obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.loginType)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.effectTime)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.account)
      ..writeByte(5)
      ..write(obj.token)
      ..writeByte(6)
      ..write(obj.profile)
      ..writeByte(7)
      ..write(obj.bindings)
      ..writeByte(8)
      ..write(obj.cookie);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 2;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      id: fields[0] as int,
      userName: fields[1] as String,
      type: fields[2] as int,
      status: fields[3] as int,
      whitelistAuthority: fields[4] as int,
      createTime: fields[5] as int,
      salt: fields[6] as String,
      tokenVersion: fields[7] as int,
      ban: fields[8] as int,
      baoyueVersion: fields[9] as int,
      donateVersion: fields[10] as int,
      vipType: fields[11] as int,
      viptypeVersion: fields[12] as int,
      anonimousUser: fields[13] as bool,
      uninitialized: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.whitelistAuthority)
      ..writeByte(5)
      ..write(obj.createTime)
      ..writeByte(6)
      ..write(obj.salt)
      ..writeByte(7)
      ..write(obj.tokenVersion)
      ..writeByte(8)
      ..write(obj.ban)
      ..writeByte(9)
      ..write(obj.baoyueVersion)
      ..writeByte(10)
      ..write(obj.donateVersion)
      ..writeByte(11)
      ..write(obj.vipType)
      ..writeByte(12)
      ..write(obj.viptypeVersion)
      ..writeByte(13)
      ..write(obj.anonimousUser)
      ..writeByte(14)
      ..write(obj.uninitialized);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 3;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      userType: fields[0] as int,
      avatarUrl: fields[1] as String,
      vipType: fields[2] as int,
      authStatus: fields[3] as int,
      djStatus: fields[4] as int,
      detailDescription: fields[5] as String,
      experts: (fields[6] as Map).cast<String, dynamic>(),
      expertTags: fields[7] as dynamic,
      accountStatus: fields[8] as int,
      nickname: fields[9] as String,
      birthday: fields[10] as int,
      gender: fields[11] as int,
      province: fields[12] as int,
      city: fields[13] as int,
      avatarImgId: fields[14] as int,
      backgroundImgId: fields[15] as int,
      defaultAvatar: fields[16] as bool,
      mutual: fields[17] as bool,
      remarkName: fields[18] as dynamic,
      followed: fields[19] as bool,
      backgroundUrl: fields[20] as String,
      avatarImgIdStr: fields[21] as String,
      backgroundImgIdStr: fields[22] as String,
      description: fields[23] as String,
      userId: fields[24] as int,
      signature: fields[25] as String,
      authority: fields[26] as int,
      followeds: fields[27] as int,
      follows: fields[28] as int,
      eventCount: fields[29] as int,
      avatarDetail: fields[30] as dynamic,
      playlistCount: fields[31] as int,
      playlistBeSubscribedCount: fields[32] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(33)
      ..writeByte(0)
      ..write(obj.userType)
      ..writeByte(1)
      ..write(obj.avatarUrl)
      ..writeByte(2)
      ..write(obj.vipType)
      ..writeByte(3)
      ..write(obj.authStatus)
      ..writeByte(4)
      ..write(obj.djStatus)
      ..writeByte(5)
      ..write(obj.detailDescription)
      ..writeByte(6)
      ..write(obj.experts)
      ..writeByte(7)
      ..write(obj.expertTags)
      ..writeByte(8)
      ..write(obj.accountStatus)
      ..writeByte(9)
      ..write(obj.nickname)
      ..writeByte(10)
      ..write(obj.birthday)
      ..writeByte(11)
      ..write(obj.gender)
      ..writeByte(12)
      ..write(obj.province)
      ..writeByte(13)
      ..write(obj.city)
      ..writeByte(14)
      ..write(obj.avatarImgId)
      ..writeByte(15)
      ..write(obj.backgroundImgId)
      ..writeByte(16)
      ..write(obj.defaultAvatar)
      ..writeByte(17)
      ..write(obj.mutual)
      ..writeByte(18)
      ..write(obj.remarkName)
      ..writeByte(19)
      ..write(obj.followed)
      ..writeByte(20)
      ..write(obj.backgroundUrl)
      ..writeByte(21)
      ..write(obj.avatarImgIdStr)
      ..writeByte(22)
      ..write(obj.backgroundImgIdStr)
      ..writeByte(23)
      ..write(obj.description)
      ..writeByte(24)
      ..write(obj.userId)
      ..writeByte(25)
      ..write(obj.signature)
      ..writeByte(26)
      ..write(obj.authority)
      ..writeByte(27)
      ..write(obj.followeds)
      ..writeByte(28)
      ..write(obj.follows)
      ..writeByte(29)
      ..write(obj.eventCount)
      ..writeByte(30)
      ..write(obj.avatarDetail)
      ..writeByte(31)
      ..write(obj.playlistCount)
      ..writeByte(32)
      ..write(obj.playlistBeSubscribedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BindingAdapter extends TypeAdapter<Binding> {
  @override
  final int typeId = 4;

  @override
  Binding read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Binding(
      bindingTime: fields[0] as int,
      refreshTime: fields[1] as int,
      tokenJsonStr: (fields[2] as Map).cast<String, dynamic>(),
      expiresIn: fields[3] as int,
      url: fields[4] as String,
      expired: fields[5] as bool,
      userId: fields[6] as int,
      id: fields[7] as int,
      type: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Binding obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.bindingTime)
      ..writeByte(1)
      ..write(obj.refreshTime)
      ..writeByte(2)
      ..write(obj.tokenJsonStr)
      ..writeByte(3)
      ..write(obj.expiresIn)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.expired)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BindingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => LoginResult(
      loginType: (json['loginType'] as num).toInt(),
      clientId: json['clientId'] as String,
      effectTime: (json['effectTime'] as num).toInt(),
      code: (json['code'] as num).toInt(),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      token: json['token'] as String,
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      bindings: (json['bindings'] as List<dynamic>)
          .map((e) => Binding.fromJson(e as Map<String, dynamic>))
          .toList(),
      cookie: json['cookie'] as String,
    );

Map<String, dynamic> _$LoginResultToJson(LoginResult instance) =>
    <String, dynamic>{
      'loginType': instance.loginType,
      'clientId': instance.clientId,
      'effectTime': instance.effectTime,
      'code': instance.code,
      'account': instance.account,
      'token': instance.token,
      'profile': instance.profile,
      'bindings': instance.bindings,
      'cookie': instance.cookie,
    };

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: (json['id'] as num).toInt(),
      userName: json['userName'] as String,
      type: (json['type'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      whitelistAuthority: (json['whitelistAuthority'] as num).toInt(),
      createTime: (json['createTime'] as num).toInt(),
      salt: json['salt'] as String,
      tokenVersion: (json['tokenVersion'] as num).toInt(),
      ban: (json['ban'] as num).toInt(),
      baoyueVersion: (json['baoyueVersion'] as num).toInt(),
      donateVersion: (json['donateVersion'] as num).toInt(),
      vipType: (json['vipType'] as num).toInt(),
      viptypeVersion: (json['viptypeVersion'] as num).toInt(),
      anonimousUser: json['anonimousUser'] as bool,
      uninitialized: json['uninitialized'] as bool,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'type': instance.type,
      'status': instance.status,
      'whitelistAuthority': instance.whitelistAuthority,
      'createTime': instance.createTime,
      'salt': instance.salt,
      'tokenVersion': instance.tokenVersion,
      'ban': instance.ban,
      'baoyueVersion': instance.baoyueVersion,
      'donateVersion': instance.donateVersion,
      'vipType': instance.vipType,
      'viptypeVersion': instance.viptypeVersion,
      'anonimousUser': instance.anonimousUser,
      'uninitialized': instance.uninitialized,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      userType: (json['userType'] as num).toInt(),
      avatarUrl: json['avatarUrl'] as String,
      vipType: (json['vipType'] as num).toInt(),
      authStatus: (json['authStatus'] as num).toInt(),
      djStatus: (json['djStatus'] as num).toInt(),
      detailDescription: json['detailDescription'] as String,
      experts: json['experts'] as Map<String, dynamic>,
      expertTags: json['expertTags'],
      accountStatus: (json['accountStatus'] as num).toInt(),
      nickname: json['nickname'] as String,
      birthday: (json['birthday'] as num).toInt(),
      gender: (json['gender'] as num).toInt(),
      province: (json['province'] as num).toInt(),
      city: (json['city'] as num).toInt(),
      avatarImgId: (json['avatarImgId'] as num).toInt(),
      backgroundImgId: (json['backgroundImgId'] as num).toInt(),
      defaultAvatar: json['defaultAvatar'] as bool,
      mutual: json['mutual'] as bool,
      remarkName: json['remarkName'],
      followed: json['followed'] as bool,
      backgroundUrl: json['backgroundUrl'] as String,
      avatarImgIdStr: json['avatarImgIdStr'] as String,
      backgroundImgIdStr: json['backgroundImgIdStr'] as String,
      description: json['description'] as String,
      userId: (json['userId'] as num).toInt(),
      signature: json['signature'] as String,
      authority: (json['authority'] as num).toInt(),
      followeds: (json['followeds'] as num).toInt(),
      follows: (json['follows'] as num).toInt(),
      eventCount: (json['eventCount'] as num).toInt(),
      avatarDetail: json['avatarDetail'],
      playlistCount: (json['playlistCount'] as num).toInt(),
      playlistBeSubscribedCount:
          (json['playlistBeSubscribedCount'] as num).toInt(),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'userType': instance.userType,
      'avatarUrl': instance.avatarUrl,
      'vipType': instance.vipType,
      'authStatus': instance.authStatus,
      'djStatus': instance.djStatus,
      'detailDescription': instance.detailDescription,
      'experts': instance.experts,
      'expertTags': instance.expertTags,
      'accountStatus': instance.accountStatus,
      'nickname': instance.nickname,
      'birthday': instance.birthday,
      'gender': instance.gender,
      'province': instance.province,
      'city': instance.city,
      'avatarImgId': instance.avatarImgId,
      'backgroundImgId': instance.backgroundImgId,
      'defaultAvatar': instance.defaultAvatar,
      'mutual': instance.mutual,
      'remarkName': instance.remarkName,
      'followed': instance.followed,
      'backgroundUrl': instance.backgroundUrl,
      'avatarImgIdStr': instance.avatarImgIdStr,
      'backgroundImgIdStr': instance.backgroundImgIdStr,
      'description': instance.description,
      'userId': instance.userId,
      'signature': instance.signature,
      'authority': instance.authority,
      'followeds': instance.followeds,
      'follows': instance.follows,
      'eventCount': instance.eventCount,
      'avatarDetail': instance.avatarDetail,
      'playlistCount': instance.playlistCount,
      'playlistBeSubscribedCount': instance.playlistBeSubscribedCount,
    };

Binding _$BindingFromJson(Map<String, dynamic> json) => Binding(
      bindingTime: (json['bindingTime'] as num).toInt(),
      refreshTime: (json['refreshTime'] as num).toInt(),
      tokenJsonStr: json['tokenJsonStr'] as Map<String, dynamic>,
      expiresIn: (json['expiresIn'] as num).toInt(),
      url: json['url'] as String,
      expired: json['expired'] as bool,
      userId: (json['userId'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$BindingToJson(Binding instance) => <String, dynamic>{
      'bindingTime': instance.bindingTime,
      'refreshTime': instance.refreshTime,
      'tokenJsonStr': instance.tokenJsonStr,
      'expiresIn': instance.expiresIn,
      'url': instance.url,
      'expired': instance.expired,
      'userId': instance.userId,
      'id': instance.id,
      'type': instance.type,
    };
