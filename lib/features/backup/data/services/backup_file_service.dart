import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final backupFileServiceProvider = Provider<BackupFileService>((ref) {
  return const BackupFileService();
});

class BackupFileService {
  static const _channel = MethodChannel("macro_diary/backup_files");

  const BackupFileService();

  Future<String?> exportBackup({
    required String fileName,
    required String contents,
  }) async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<String>(
        "exportBackup",
        {
          "fileName": fileName,
          "contents": contents,
          "mimeType": "application/json",
        },
      );
    }

    if (Platform.isIOS) {
      throw UnsupportedError("Backup export is only wired for Android.");
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/$fileName");
    await file.writeAsString(contents);
    return file.path;
  }

  Future<String?> importBackup() async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<String>(
        "importBackup",
        {
          "mimeType": "application/json",
        },
      );
    }

    if (Platform.isIOS) {
      throw UnsupportedError("Backup import is only wired for Android.");
    }

    throw UnsupportedError("Backup import is only available on mobile.");
  }
}
