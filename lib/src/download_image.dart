// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Download Image into download file for android
Future<String?> saveFile({
  required String filename,
  required Uint8List bytes,
}) async {
  final String dir;
  if (Platform.isAndroid) {
    dir = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOADS,
    );
  } else {
    dir = (await getApplicationDocumentsDirectory()).path;
  }

  final imageFile = File(path.join(dir, "$filename.png"));
  if (!await imageFile.exists()) {
    imageFile.create();
    imageFile.writeAsBytes(bytes);
    debugPrint("image-path: exists ${imageFile.path}");
    return imageFile.path;
  } else {
    final date = DateTime.now().millisecondsSinceEpoch;
    final newImageFile = File(path.join(dir, "${filename}_$date.png"));
    debugPrint("image-path: ${newImageFile.path}");
    newImageFile.create();
    newImageFile.writeAsBytes(bytes);
    return newImageFile.path;
  }
}

/// Check storage permission then download
Future<String?> downloadImage(Uint8List bytes, String filename) async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    final storage = await Permission.storage.request();
    final manageExternalStorage =
        await Permission.manageExternalStorage.request();

    if (storage.isGranted || manageExternalStorage.isGranted) {
      status = PermissionStatus.granted;
      debugPrint("DownloadImage: permission granted");
    } else {
      debugPrint("DownloadImage: permission denied");
      return null;
    }
  }
  return await saveFile(filename: filename, bytes: bytes);
}

Future<void> downloadAndOpenImage({
  required BuildContext context,
  required Uint8List bytes,
  required String filename,
}) async {
  if (kIsWeb) {
    await WebImageDownloader.downloadImageFromUInt8List(
      uInt8List: bytes,
      name: filename,
      imageType: ImageType.png,
      imageQuality: 1,
    );
  } else {
    final path = await downloadImage(bytes, filename);

    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Permission denied"),
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Image downloaded"),
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(
          label: "Open",
          onPressed: () {
            OpenFilex.open(path, type: "image/png");
          },
        ),
      ),
    );
  }
}
