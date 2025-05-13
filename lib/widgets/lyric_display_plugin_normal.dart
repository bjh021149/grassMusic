import 'package:flutter/material.dart';

class LyricsDisplay extends StatelessWidget {
  final String lyrics; // 完整的歌词文本
  final double currentPosition; // 当前播放进度（毫秒）
  final TextStyle normalStyle; // 普通歌词样式
  final TextStyle highlightStyle; // 高亮歌词样式

  const LyricsDisplay({
    super.key,
    required this.lyrics,
    required this.currentPosition,
    this.normalStyle = const TextStyle(color: Colors.white, fontSize: 16),
    this.highlightStyle = const TextStyle(
      color: Colors.blue,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    // 将歌词解析为列表
    final parsedLyrics = _parseLyrics(lyrics);

    // 找到当前播放的歌词行索引
    final currentIndex = _findCurrentLyricIndex(parsedLyrics, currentPosition);

    return ListView.builder(
      itemCount: parsedLyrics.length,
      itemBuilder: (context, index) {
        final line = parsedLyrics[index];
        final isHighlighted = index == currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            line['text']!,
            textAlign: TextAlign.center,
            style: isHighlighted ? highlightStyle : normalStyle,
          ),
        );
      },
    );
  }

  /// 解析歌词文本为带时间戳的列表
  List<Map<String, dynamic>> _parseLyrics(String lyrics) {
    final lines = lyrics.split('\n');
    final parsed = <Map<String, dynamic>>[];

    for (var line in lines) {
      final match = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)').firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = double.parse(match.group(2)!);
        final text = match.group(3) ?? '';
        parsed.add({
          'time':
              Duration(
                minutes: minutes,
                seconds: seconds.toInt(),
              ).inMilliseconds,
          'text': text,
        });
      }
    }

    return parsed;
  }

  /// 根据当前播放时间找到对应的歌词行索引
  int _findCurrentLyricIndex(
    List<Map<String, dynamic>> lyrics,
    double currentPosition,
  ) {
    for (int i = 0; i < lyrics.length; i++) {
      final currentTime = lyrics[i]['time'] as int;
      final nextTime =
          i + 1 < lyrics.length
              ? lyrics[i + 1]['time'] as int
              : double.infinity;

      if (currentPosition >= currentTime && currentPosition < nextTime) {
        return i;
      }
    }
    return -1; // 未找到匹配的歌词行
  }
}
