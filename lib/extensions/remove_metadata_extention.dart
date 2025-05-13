extension LyricsParser on String {
  /// 分离歌词中的元信息和歌词内容
  /// 返回格式: {"meta": "元信息", "lyrics": "歌词内容"}
  Map<String, String> parsedLyrics() {
    final lines = split('\n');
    final metaList = <String>[];
    final lyricsList = <String>[];

    for (final line in lines) {
      if (line.trim().startsWith('{') && line.trim().endsWith('}')) {
        // 提取元信息（JSON格式）
        metaList.add(line);
      } else if (line.trim().isNotEmpty) {
        // 提取歌词内容（去除残留的 {} 内容）
        final cleanedLyrics = line.replaceAll(RegExp(r'\{[^}]*\}'), '');
        lyricsList.add(cleanedLyrics);
      }
    }
    //print(lyricsList.join('\n'));
    return {'meta': metaList.join('\n'), 'lyrics': lyricsList.join('\n')};
  }
}
