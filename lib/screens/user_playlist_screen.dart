import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_playlist_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_playlist.dart';
import 'login_screen.dart';
import 'playlist_detail_screen.dart';

class UserPlaylistScreen extends StatefulWidget {
  const UserPlaylistScreen({super.key});

  @override
  State<UserPlaylistScreen> createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 延迟初始化
    Future.microtask(() => _loadPlaylists());
  }

  Future<void> _loadPlaylists() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final playlistProvider = context.read<UserPlaylistProvider>();

    if (authProvider.isLoggedIn) {
      print(authProvider.isLoggedIn);
      await playlistProvider.fetchUserPlaylists(
        authProvider.user!.userId.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final playlistProvider = Provider.of<UserPlaylistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的歌单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPlaylists(),
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildContent(authProvider, playlistProvider),
    );
  }

  Widget _buildContent(
    AuthProvider authProvider,
    UserPlaylistProvider playlistProvider,
  ) {
    if (!authProvider.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('请先登录以查看您的歌单'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          content: LoginForm(
                            authProvider: authProvider,
                            onSuccess: () => Navigator.of(context).pop(),
                          ),
                        ),
                  ),
              child: const Text('登录'),
            ),
          ],
        ),
      );
    }

    if (playlistProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playlistProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: ${playlistProvider.error}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadPlaylists(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (playlistProvider.playlists.isEmpty) {
      return const Center(child: Text('您还没有创建任何歌单'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadPlaylists(),
      child: ListView.builder(
        itemCount: playlistProvider.playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlistProvider.playlists[index];
          return _buildPlaylistItem(playlist);
        },
      ),
    );
  }

  Widget _buildPlaylistItem(UserPlaylist playlist) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            playlist.coverImgUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const Icon(Icons.music_note),
          ),
        ),
        title: Text(playlist.name),
        subtitle: Text(
          '${playlist.trackCount}首 • ${playlist.playCount}次播放\n创建者: ${playlist.creator}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            playlist.subscribed
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
        onTap: () {
          // 计算初始加载数量
          final mediaQuery = MediaQuery.of(context);
          final screenHeight = mediaQuery.size.height;
          final estimatedVisibleItems = ((screenHeight - 300) / 72).floor();
          final initialLoadCount = estimatedVisibleItems.clamp(10, 25);
          // 这里可以导航到歌单详情页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PlaylistDetailScreen(
                    playlistId: playlist.id,
                    initialLoadCount: initialLoadCount,
                  ),
            ),
          );
        },
      ),
    );
  }
}
