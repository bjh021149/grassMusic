class AdvancedLyric {
  final String title;
  final String artist;
  final String album;
  final String by;
  final int offset;
  final List<AdvancedLyricLine> lines;

  AdvancedLyric({
    required this.title,
    required this.artist,
    required this.album,
    this.by = '',
    this.offset = 0,
    required this.lines,
  });

  factory AdvancedLyric.fromString(String rawLyric) {
    final lines = rawLyric.split('\n');
    String title = '';
    String artist = '';
    String album = '';
    String by = '';
    int offset = 0;
    final lyricLines = <AdvancedLyricLine>[];

    for (var line in lines) {
      if (line.startsWith('[ti:')) {
        title = line.substring(4, line.length - 1);
      } else if (line.startsWith('[ar:')) {
        artist = line.substring(4, line.length - 1);
      } else if (line.startsWith('[al:')) {
        album = line.substring(4, line.length - 1);
      } else if (line.startsWith('[by:')) {
        by = line.substring(4, line.length - 1);
      } else if (line.startsWith('[offset:')) {
        offset = int.tryParse(line.substring(8, line.length - 1)) ?? 0;
      } else if (line.startsWith('[') && line.contains(']')) {
        final timeEndIndex = line.indexOf(']');
        final timeAndDuration = line.substring(1, timeEndIndex).split(',');
        final time = int.tryParse(timeAndDuration[0]) ?? 0;
        final duration = timeAndDuration.length > 1
            ? int.tryParse(timeAndDuration[1]) ?? 0
            : 0;
        final text = line.substring(timeEndIndex + 1).trim();
        lyricLines.add(AdvancedLyricLine(time: time, duration: duration, text: text));
      }
    }

    return AdvancedLyric(
      title: title,
      artist: artist,
      album: album,
      by: by,
      offset: offset,
      lines: lyricLines,
    );
  }
}

class AdvancedLyricLine {
  final int time; // Start time in milliseconds
  final int duration; // Duration in milliseconds
  final String text;

  AdvancedLyricLine({
    required this.time,
    required this.duration,
    required this.text,
  });
}