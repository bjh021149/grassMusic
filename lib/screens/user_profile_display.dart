import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class UserProfileDrawer extends StatelessWidget {
  final AuthProvider authProvider;
  final VoidCallback onCloseDrawer;

  const UserProfileDrawer({
    super.key,
    required this.authProvider,
    required this.onCloseDrawer,
  });

  Future<void> _selectDownloadPath(BuildContext context) async {
    final currentPath = authProvider.downloadPath;
    final newPath = await showDialog<String>(
      context: context,
      builder: (context) => PathSelectionDialog(currentPath: currentPath),
    );

    if (newPath != null && newPath != currentPath) {
      await authProvider.updateDownloadPath(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (authProvider.user == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    final user = authProvider.user!;
    final theme = Theme.of(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // 顶部用户信息区域
          UserAccountsDrawerHeader(
            accountName: Text(user.nickname),
            accountEmail: Text('ID: ${user.userId}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            decoration: BoxDecoration(color: theme.primaryColor),
          ),

          // 下载路径设置
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('下载路径'),
            subtitle: Text(
              authProvider.downloadPath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectDownloadPath(context),
          ),
          const Divider(height: 1),

          // 其他设置项可以在这里添加
          /*
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('应用设置'),
            onTap: () {},
          ),
          */

          // 底部退出登录按钮
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
                onPressed: () {
                  authProvider.logout();
                  onCloseDrawer();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('退出登录'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 复用原来的路径选择对话框
class PathSelectionDialog extends StatefulWidget {
  final String currentPath;

  const PathSelectionDialog({super.key, required this.currentPath});

  @override
  State<PathSelectionDialog> createState() => _PathSelectionDialogState();
}

class _PathSelectionDialogState extends State<PathSelectionDialog> {
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.currentPath);
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置下载路径'),
      content: TextField(
        controller: _pathController,
        decoration: const InputDecoration(
          hintText: '输入自定义下载路径',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_pathController.text.trim().isNotEmpty) {
              Navigator.pop(context, _pathController.text.trim());
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}
