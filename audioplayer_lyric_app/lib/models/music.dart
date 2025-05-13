class Song {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  final int duration; // 毫秒
  late String? audioUrl;
  final bool available;
  final String? size;

  Song({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.duration,
    this.audioUrl,
    this.available = true,
    this.size,
  });

  // 添加 copyWith 方法
  Song copyWith({
    String? id,
    String? name,
    List<Artist>? artists,
    Album? album,
    int? duration,
    String? audioUrl,
    bool? available,
    String? size,
  }) {
    return Song(
      id: id ?? this.id,
      name: name ?? this.name,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      available: available ?? this.available,
      size: size ?? this.size,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      artists:
          (json['ar'] as List? ?? []).map((e) => Artist.fromJson(e)).toList(),
      album: Album.fromJson(json['al'] ?? {}),
      duration: json['dt'] ?? 0,
      audioUrl: json['audioUrl'],
      available: json['available'] ?? true,
      size: json['size'],
    );
  }

  String get artistNames => artists.map((e) => e.name).join(' / ');

  // 格式化持续时间 (mm:ss)
  String get formattedDuration {
    final duration = Duration(milliseconds: this.duration);
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}

class Artist {
  final String id;
  final String name;

  Artist({required this.id, required this.name});

  Artist copyWith({String? id, String? name}) {
    return Artist(id: id ?? this.id, name: name ?? this.name);
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(id: json['id']?.toString() ?? '', name: json['name'] ?? '');
  }

  @override
  String toString() => name;
}

class Album {
  final String id;
  final String name;
  final String picUrl;

  Album({required this.id, required this.name, required this.picUrl});

  Album copyWith({String? id, String? name, String? picUrl}) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      picUrl: picUrl ?? this.picUrl,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      picUrl: json['picUrl'] ?? json['picUrl'] ?? json['coverImgUrl'] ?? '',
    );
  }

  @override
  String toString() => name;
}

class LyricResponse {
  final bool sgc;
  final bool sfy;
  final bool qfy;
  final Lrc lrc;
  final Yrc yrc;
  final int code;

  LyricResponse({
    required this.sgc,
    required this.sfy,
    required this.qfy,
    required this.lrc,
    required this.yrc,
    required this.code,
  });

  factory LyricResponse.fromJson(Map<String, dynamic> json) {
    return LyricResponse(
      sgc: json['sgc'] ?? false,
      sfy: json['sfy'] ?? false,
      qfy: json['qfy'] ?? false,
      lrc: Lrc.fromJson(json['lrc'] ?? {}),
      yrc: Yrc.fromJson(json['yrc'] ?? {}),
      code: json['code'] ?? 0,
    );
  }
}

class Lrc {
  final int version;
  final String lyric;

  Lrc({required this.version, required this.lyric});

  factory Lrc.fromJson(Map<String, dynamic> json) {
    return Lrc(version: json['version'] ?? 0, lyric: json['lyric'] ?? '');
  }
}

class Yrc {
  final int version;
  final String lyric;

  Yrc({required this.version, required this.lyric});

  factory Yrc.fromJson(Map<String, dynamic> json) {
    return Yrc(version: json['version'] ?? 0, lyric: json['lyric'] ?? '');
  }
}

class LyricLine {
  final Duration startTime;
  final Duration endTime;
  final String text;
  final List<LyricWord>? words; // 仅YRC使用

  LyricLine({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.words,
  });

  @override
  String toString() {
    return '${startTime.inMilliseconds}-${endTime.inMilliseconds}: $text';
  }
}

class LyricWord {
  final Duration startTime;
  final Duration duration;
  final String word;

  LyricWord({
    required this.startTime,
    required this.duration,
    required this.word,
  });

  @override
  String toString() {
    return '${startTime.inMilliseconds} (${duration.inMilliseconds}): $word';
  }
}

class RawLyricResponse {
  final bool sgc;
  final bool sfy;
  final bool qfy;
  final String lrc;
  final String tlyric;
  final String klyric;
  final String yrc;
  final String romalrc;
  final int code;

  RawLyricResponse({
    required this.sgc,
    required this.sfy,
    required this.qfy,
    required this.lrc,
    required this.tlyric,
    required this.klyric,
    required this.yrc,
    required this.romalrc,
    required this.code,
  });

  factory RawLyricResponse.fromJson(Map<String, dynamic> json) {
    return RawLyricResponse(
      sgc: json['sgc'] ?? false,
      sfy: json['sfy'] ?? false,
      qfy: json['qfy'] ?? false,
      lrc: json['lrc']?.toString() ?? '',
      tlyric: json['tlyric']?.toString() ?? '',
      klyric: json['klyric']?.toString() ?? '',
      yrc: json['yrc']?.toString() ?? '',
      romalrc: json['romalrc']?.toString() ?? '',
      code: json['code'] ?? 0,
    );
  }

  bool get hasLrc => lrc.isNotEmpty;
  bool get hasTranslation => tlyric.isNotEmpty;
  bool get hasKaraoke => klyric.isNotEmpty;
  bool get hasWordByWord => yrc.isNotEmpty;
  bool get hasRomaji => romalrc.isNotEmpty;
}
