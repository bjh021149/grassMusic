import 'package:flutter/material.dart';
import '../models/music.dart';

class DisplaySong extends StatelessWidget {
  final Song song;
  final double imageSize;
  final TextStyle? titleStyle;
  final TextStyle? artistStyle;
  final TextStyle? durationStyle;
  final bool showDuration;

  const DisplaySong({
    super.key,
    required this.song,
    this.imageSize = 80.0,
    this.titleStyle,
    this.artistStyle,
    this.durationStyle,
    this.showDuration = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 专辑封面
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            song.album.picUrl,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note, size: 40),
                ),
          ),
        ),

        const SizedBox(width: 16),

        // 歌曲信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 歌曲名称
              Text(
                song.name,
                style:
                    titleStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // 艺术家
              Text(
                song.artistNames,
                style:
                    artistStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 时长
        if (showDuration) ...[
          const SizedBox(width: 8),
          Text(
            song.formattedDuration,
            style:
                durationStyle ??
                theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
