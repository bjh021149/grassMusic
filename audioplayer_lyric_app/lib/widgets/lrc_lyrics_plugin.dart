import 'package:flutter/material.dart';

class LrcLyricsWidget extends StatefulWidget {
  final String lrcText;
  final Duration position;
  final Duration duration;
  final bool isLyricChanged;
  const LrcLyricsWidget({
    super.key,
    required this.lrcText,
    required this.position,
    required this.duration,
    required this.isLyricChanged,
  });

  @override
  State<LrcLyricsWidget> createState() => _LrcLyricsWidgetState();
}

class _LrcLyricsWidgetState extends State<LrcLyricsWidget> {
  List<LrcLine> _lines = [];
  int _currentLineIndex = -1;
  String _cachedLyrics = '';

  @override
  void initState() {
    super.initState();
    _parseLrc();
  }

  @override
  void didUpdateWidget(LrcLyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLyricChanged && widget.lrcText.isNotEmpty) {
      _cachedLyrics = widget.lrcText;
      _parseLrc();
    } else {
      _cachedLyrics = '[00:00.000]听';
    }
    _updateCurrentLine();
  }

  void _parseLrc() {
    _lines = [];
    final lines = _cachedLyrics.split('\n');

    for (var line in lines) {
      final timeTags = RegExp(r'\[(\d+):(\d+)\.(\d+)\]').allMatches(line);
      if (timeTags.isEmpty) continue;

      final text = line.substring(timeTags.last.end);
      if (text.trim().isEmpty) continue;

      for (var tag in timeTags) {
        final minutes = int.parse(tag.group(1)!);
        final seconds = int.parse(tag.group(2)!);
        final milliseconds = int.parse(tag.group(3)!);

        final time = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        _lines.add(LrcLine(time: time, text: text));
      }
    }

    // Sort lines by time
    _lines.sort((a, b) => a.time.compareTo(b.time));

    // Calculate end times (rough estimation)
    for (int i = 0; i < _lines.length; i++) {
      if (i < _lines.length - 1) {
        _lines[i].endTime = _lines[i + 1].time;
      } else {
        // Last line ends at the duration of the song
        _lines[i].endTime = Duration(seconds: widget.duration.inSeconds);
      }
    }

    _updateCurrentLine();
  }

  void _updateCurrentLine() {
    if (_lines.isEmpty) return;

    int newIndex = -1;
    for (int i = 0; i < _lines.length; i++) {
      if (widget.position >= _lines[i].time &&
          (i == _lines.length - 1 || widget.position < _lines[i + 1].time)) {
        newIndex = i;
        break;
      }
    }

    if (newIndex != -1 && newIndex != _currentLineIndex) {
      setState(() {
        _currentLineIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const Center(child: Text('暂无歌词'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentLineIndex > 0)
          _buildLyricLine(_lines[_currentLineIndex - 1].text, false),

        if (_currentLineIndex != -1)
          _buildLyricLine(
            _lines[_currentLineIndex].text,
            true,
            progress: _calculateProgress(),
          ),

        if (_currentLineIndex < _lines.length - 1)
          _buildLyricLine(_lines[_currentLineIndex + 1].text, false),
      ],
    );
  }

  double _calculateProgress() {
    if (_currentLineIndex == -1) return 0;

    final line = _lines[_currentLineIndex];
    final position = widget.position;

    if (position <= line.time) return 0;
    if (position >= line.endTime) return 1;

    return (position - line.time).inMilliseconds /
        (line.endTime - line.time).inMilliseconds;
  }

  Widget _buildLyricLine(String text, bool isCurrent, {double progress = 0}) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: LyricLinePainter(
          text: text,
          isCurrent: isCurrent,
          progress: isCurrent ? progress : 0,
        ),
      ),
    );
  }
}

class LyricLinePainter extends CustomPainter {
  final String text;
  final bool isCurrent;
  final double progress;

  static const defaultStyle = TextStyle(fontSize: 18, color: Colors.grey);

  static const highlightStyle = TextStyle(
    fontSize: 22,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );

  LyricLinePainter({
    required this.text,
    required this.isCurrent,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = isCurrent ? highlightStyle : defaultStyle;

    // Paint the whole line first (base)
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final xOffset = (size.width - textPainter.width) / 2;
    final yOffset = (size.height - textPainter.height) / 2;

    if (isCurrent) {
      // Paint the base (non-highlighted part)
      textPainter.paint(canvas, Offset(xOffset, yOffset));

      // Paint the highlighted part
      if (progress > 0) {
        final clipWidth = textPainter.width * progress;
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(xOffset, 0, clipWidth, size.height));

        textPainter.text = TextSpan(
          text: text,
          style: highlightStyle.copyWith(color: Colors.orange),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(xOffset, yOffset));

        canvas.restore();
      }
    } else {
      // Paint non-current lines normally
      textPainter.paint(canvas, Offset(xOffset, yOffset));
    }
  }

  @override
  bool shouldRepaint(covariant LyricLinePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.isCurrent != isCurrent ||
        oldDelegate.progress != progress;
  }
}

class LrcLine {
  final Duration time;
  final String text;
  Duration endTime;

  LrcLine({
    required this.time,
    required this.text,
    this.endTime = Duration.zero,
  });
}
