// audio_downloader.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class AudioDownloader {
  final Dio _dio = Dio();

  // 修改下载方法，接受自定义路径参数
  Future<File?> downloadAudio(
    String audioUrl,
    String artist,
    String album,
    String fileName,
    String downloadPath,
  ) async {
    // 跳过权限检查（Windows 不需要）
    if (!Platform.isWindows) {
      final status = await Permission.storage.request();
      if (!status.isGranted) throw Exception('Permission denied');
    }

    String sanitizeFileName(String name) {
      return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    }

    artist = sanitizeFileName(artist);
    album = sanitizeFileName(album);
    fileName = sanitizeFileName(fileName);
    try {
      // 使用传入的downloadPath而不是固定路径
      final Directory dir = Directory(downloadPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final String savePath = path.join(downloadPath, artist, album, fileName);
      debugPrint('savePath: $savePath');
      await _dio.download(
        audioUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      return File(savePath);
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  // 修改文件存在检查方法，使用自定义路径
  Future<bool> fileExists(String fileName, String downloadPath) async {
    try {
      final String filePath = '$downloadPath/$fileName';
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  // 修改获取文件列表方法，使用自定义路径
  Future<List<File>> getDownloadedFiles(String downloadPath) async {
    try {
      final Directory dir = Directory(downloadPath);
      if (!await dir.exists()) {
        return [];
      }
      return dir.list().where((file) => file is File).cast<File>().toList();
    } catch (e) {
      print('Error getting downloaded files: $e');
      return [];
    }
  }
}

final Dio _dio = Dio();

// 下载音频文件到本地
Future<File?> downloadAudio(String audioUrl, {String? fileName}) async {
  // 检查并请求存储权限
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception('Storage permission not granted');
  }

  try {
    // 获取应用文档目录
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String downloadPath = '${appDocDir.path}/downloads';

    // 确保下载目录存在
    final Directory dir = Directory(downloadPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 如果没有提供文件名，从URL中提取
    String saveFileName =
        fileName ??
        audioUrl.split('/').last.split('?').first.replaceAll('%20', ' ');

    // 如果文件名没有扩展名，添加.mp3
    if (!saveFileName.contains('.')) {
      saveFileName += '.mp3';
    }

    final String savePath = '$downloadPath/$saveFileName';

    // 下载文件
    await _dio.download(
      audioUrl,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
            'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
          );
        }
      },
    );

    return File(savePath);
  } catch (e) {
    print('Download error: $e');
    return null;
  }
}

// 检查文件是否已存在
Future<bool> fileExists(String fileName) async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocDir.path}/downloads/$fileName';
    return await File(filePath).exists();
  } catch (e) {
    return false;
  }
}

// 获取已下载的文件列表
Future<List<File>> getDownloadedFiles() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String downloadPath = '${appDocDir.path}/downloads';
    final Directory dir = Directory(downloadPath);

    if (!await dir.exists()) {
      return [];
    }

    return dir.list().where((file) => file is File).cast<File>().toList();
  } catch (e) {
    print('Error getting downloaded files: $e');
    return [];
  }
}
