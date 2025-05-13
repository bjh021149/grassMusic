import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayer_lyric_app/providers/audioplayers_playlist_provider.dart';
import 'package:audioplayer_lyric_app/models/music.dart';

class AudioPlaylistScreen extends StatefulWidget {
  const AudioPlaylistScreen({super.key});

  @override
  State<AudioPlaylistScreen> createState() => _AudioPlaylistScreenState();
}

class _AudioPlaylistScreenState extends State<AudioPlaylistScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<AudioPlaylistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('播放列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: playlistProvider.toggleShuffle,
            tooltip: '随机播放',
            color: playlistProvider.isShuffleEnabled ? Colors.blue : null,
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: playlistProvider.toggleListLoop,
            tooltip: '列表循环',
            color: playlistProvider.isListLoopEnabled ? Colors.blue : null,
          ),
          IconButton(
            onPressed: playlistProvider.toggleRepeat,
            icon: const Icon(Icons.loop),
            tooltip: '单曲循环',
            color: playlistProvider.isRepeatEnabled ? Colors.blue : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                playlistProvider.playlist.isEmpty
                    ? null
                    : () => _showClearPlaylistDialog(context),
            tooltip: '清空列表',
          ),
        ],
      ),
      body:
          playlistProvider.playlist.isEmpty
              ? const Center(
                child: Text('播放列表为空', style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                controller: _scrollController,
                itemCount: playlistProvider.playlist.length,
                itemBuilder:
                    (context, index) => _buildPlaylistItem(
                      playlistProvider.playlist[index],
                      index,
                      playlistProvider,
                    ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (playlistProvider.playlist.isNotEmpty) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildPlaylistItem(
    Song song,
    int index,
    AudioPlaylistProvider provider,
  ) {
    final isCurrentSong = provider.currentSong == song && provider.isPlaying;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.album.picUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
        ),
      ),
      title: Text(
        song.name,
        style: TextStyle(
          fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
          color: isCurrentSong ? Colors.blue : null,
        ),
      ),
      subtitle: Text(
        song.artists.map((a) => a.name).join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(song.formattedDuration),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => provider.playSong(song),
            tooltip: '播放此歌曲',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => provider.removeFromPlaylist(song),
            tooltip: '从列表移除',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed:
                () async => {
                  await provider.downloadSong(song),
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('正在下载 "${song.name}" 到本地'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    ),
                },
            tooltip: '下载歌曲',
          ),
        ],
      ),
      onTap: () => provider.playSong(song),
    );
  }

  Future<void> _showClearPlaylistDialog(BuildContext context) async {
    final provider = Provider.of<AudioPlaylistProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('清空播放列表'),
            content: const Text('确定要清空整个播放列表吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  provider.clearPlaylist();
                  Navigator.pop(context);
                },
                child: const Text('清空', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
