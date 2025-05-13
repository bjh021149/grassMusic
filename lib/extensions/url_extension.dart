// url_file_extension.dart
import 'package:dio/dio.dart';

extension UrlFileExtension on String {
  /// 从URL字符串中提取文件名（带扩展名）
  String extractFileNameFromUrl() {
    try {
      final uri = Uri.parse(this);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last.split('?').first.replaceAll('%20', ' ');
      }
    } catch (e) {
      print('Error parsing URL: $e');
    }
    return 'file_${DateTime.now().millisecondsSinceEpoch}';
  }
}

extension HeadersFileExtension on Headers {
  /// 从Headers中提取文件名（带扩展名）
  String? extractFileNameFromHeaders() {
    final contentDisposition = value('content-disposition');
    if (contentDisposition != null) {
      // 匹配 filename="xxx.xxx" 或 filename=xxx.xxx 格式
      final filenameMatch = RegExp(
        r'filename(?:\*?)=(?:"([^"]+)"|([^;]+))',
      ).firstMatch(contentDisposition);
      return filenameMatch?.group(1)?.trim();
    }
    return null;
  }

  /// 根据Content-Type获取推荐的文件扩展名
  String? getRecommendedExtension() {
    final contentType = value('content-type')?.split(';').first.trim();
    if (contentType == null) return null;

    const extensionMap = {
      'audio/mpeg': 'mp3',
      'audio/wav': 'wav',
      'audio/aac': 'aac',
      'audio/ogg': 'ogg',
      'audio/x-m4a': 'm4a',
      'audio/flac': 'flac',
      'application/octet-stream': 'bin',
    };

    return extensionMap[contentType.toLowerCase()];
  }
}

extension FileNameExtension on String {
  /// 确保文件名有合适的扩展名
  String ensureFileExtension([String? fallbackExtension = 'mp3']) {
    if (contains('.')) return this;
    return '$this.$fallbackExtension';
  }

  /// 从已有文件名中提取扩展名
  String? get fileExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < length - 1) {
      return substring(dotIndex + 1).toLowerCase();
    }
    return null;
  }
}
