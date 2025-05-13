extension YrcLyricConverter on String {
  /// 单行歌词格式转换
  String convertYrcToNewFormat() {
    if (startsWith('{')) return this; // 保持元数据行不变

    final lineRegex = RegExp(r'^\[(\d+),(\d+)\](.*)');
    final lineMatch = lineRegex.firstMatch(this);
    if (lineMatch == null) return this;

    final buffer = StringBuffer(
      '[${lineMatch.group(1)},${lineMatch.group(2)}]',
    );
    final content = lineMatch.group(3)!;

    // 修正正则表达式捕获')'和'('之间或最后一个')'之后的字符组
    final charRegex = RegExp(r'\((\d+),(\d+),\d+\)([^()\s]+)|\)([^()\s]+)');
    var lastPos = 0;

    for (final match in charRegex.allMatches(content)) {
      if (match.start > lastPos) {
        buffer.write(content.substring(lastPos, match.start));
      }

      final charGroup = match.group(3) ?? match.group(4);
      final startTime = match.group(1);
      final duration = match.group(2);

      if (startTime != null && duration != null) {
        buffer.write('$charGroup($startTime,$duration)');
      } else {
        buffer.write(charGroup); // 无时间参数的字符
      }

      lastPos = match.end;
    }

    if (lastPos < content.length) {
      buffer.write(content.substring(lastPos));
    }

    return buffer.toString();
  }

  /// 多行歌词转换后合并返回（保留换行符）
  String convertYrcLinesToMergedString() {
    final buffer = StringBuffer();
    for (final line in split('\n')) {
      buffer.writeln(line.convertYrcToNewFormat());
    }
    return buffer.toString();
  }

  /// 多行歌词转换后合并返回（可选是否保留换行符）
  String convertYrcLines({bool keepLineBreaks = true}) {
    final buffer = StringBuffer();
    final lines = split('\n');

    for (int i = 0; i < lines.length; i++) {
      buffer.write(lines[i].convertYrcToNewFormat());
      if (keepLineBreaks && i != lines.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}
