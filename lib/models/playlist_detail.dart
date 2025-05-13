import '../models/music.dart';
import '../models/auth.dart';

class PlaylistDetail {
  final String id;
  final String name;
  final String coverImgUrl;
  final UserProfile creator;
  final String description;
  final bool subscribed;
  final int trackCount;
  final int playCount;
  List<Song> songs; // 改为非final，以便更新
  final List<String> allTrackIds; // 全部歌曲ID
  List<String> loadedTrackIds; // 已加载的歌曲ID
  final DateTime createTime;
  final DateTime updateTime;

  PlaylistDetail({
    required this.id,
    required this.name,
    required this.coverImgUrl,
    required this.creator,
    required this.description,
    required this.subscribed,
    required this.trackCount,
    required this.playCount,
    required this.songs,
    required this.allTrackIds,
    required this.loadedTrackIds,
    required this.createTime,
    required this.updateTime,
  });

  // 添加加载更多歌曲的方法
  void addMoreSongs(List<Song> newSongs, List<String> newTrackIds) {
    songs.addAll(newSongs);
    loadedTrackIds.addAll(newTrackIds);
  }

  // 判断是否还有更多歌曲可以加载
  bool get hasMoreSongs => loadedTrackIds.length < allTrackIds.length;
}
