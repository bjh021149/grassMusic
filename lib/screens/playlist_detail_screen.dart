import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_detail.dart';
import '../services/netease_api.dart';
//import '../providers/just_audio_state_provider.dart';
import '../providers/audioplayers_playlist_provider.dart';
import '../models/music.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final int initialLoadCount;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.initialLoadCount = 20,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Future<PlaylistDetail> _playlistDetailFuture;
  bool _isLoading = false;
  bool _isloadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetail();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylistDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = Provider.of<NeteaseMusicApi>(context, listen: false);
      _playlistDetailFuture = api.getPlaylistDetailFull(
        widget.playlistId,
        initialLoadCount: widget.initialLoadCount,
      );
      await _playlistDetailFuture;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = Provider.of<NeteaseMusicApi>(context, listen: false);

      _playlistDetailFuture = api.getPlaylistDetailFull(
        widget.playlistId,
        initialLoadCount: widget.initialLoadCount,
      );
      await _playlistDetailFuture;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreSongs();
    }
  }

  Future<void> _loadMoreSongs() async {
    if (_isloadingMore) return;

    setState(() {
      _isloadingMore = true;
    });

    try {
      final playlist = await _playlistDetailFuture;
      if (!playlist.hasMoreSongs) return;
      // Check if the playlist is already loading more songs
      if (!mounted) return;
      final api = Provider.of<NeteaseMusicApi>(context, listen: false);
      final newSongs = await api.loadMoreSongs(playlist);

      if (mounted) {
        setState(() {
          playlist.addMoreSongs(newSongs, newSongs.map((s) => s.id).toList());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isloadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歌单详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: '刷新',
          ),
          //IconButton(onPressed: , icon: icon)
        ],
      ),
      body: FutureBuilder<PlaylistDetail>(
        future: _playlistDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _refresh, child: const Text('重试')),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('没有找到歌单信息'));
          }

          final playlist = snapshot.data!;
          return _buildPlaylistDetail(playlist);
        },
      ),
    );
  }

  Widget _buildPlaylistDetail(PlaylistDetail playlist) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(playlist.creator.avatarUrl),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(playlist.creator.nickname),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${playlist.trackCount}首 • 播放 ${playlist.playCount}次',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (playlist.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    playlist.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < playlist.songs.length) {
                return _buildSongItem(playlist.songs[index]);
              } else if (playlist.hasMoreSongs) {
                return _buildLoadMoreIndicator();
              } else {
                return _buildEndOfList();
              }
            },
            childCount: playlist.songs.length + (playlist.hasMoreSongs ? 1 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child:
            _isloadingMore
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _loadMoreSongs,
                  child: const Text('加载更多'),
                ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: Text('已经到底了', style: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildSongItem(Song song) {
    final audioProvider = Provider.of<AudioPlaylistProvider>(
      context,
      listen: false,
    );

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.album.picUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => const Icon(Icons.music_note),
        ),
      ),
      title: Text(song.name),
      subtitle: Text(
        song.artists.map((a) => a.name).join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(song.duration),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              audioProvider.addToPlaylist(song);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已添加 "${song.name}" 到播放列表'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: '添加到播放列表',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              audioProvider.downloadSong(song);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('正在下载 "${song.name}" 到本地'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
            tooltip: '下载歌曲',
          ),
        ],
      ),
      onTap: () {
        audioProvider.playSong(song);
      },
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
