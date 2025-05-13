class AuthInfo {
  final String musicU;
  final String userId;
  final String csrf;

  AuthInfo({required this.musicU, required this.userId, required this.csrf});

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      musicU: json['musicU'] ?? '',
      userId: json['userId'] ?? '',
      csrf: json['csrf'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'musicU': musicU, 'userId': userId, 'csrf': csrf};
  }
}

class UserProfile {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final String? backgroundUrl;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    this.backgroundUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '未知用户',
      avatarUrl:
          json['avatarUrl']?.toString() ??
          'https://p3.music.126.net/SUeqMM8HOIpHv9Nhl9qt9w==/109951165647004069.jpg',
      backgroundUrl: json['backgroundUrl']?.toString(),
    );
  }
}
