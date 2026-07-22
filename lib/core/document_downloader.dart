import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

/// Downloads a document so it lands where the user actually expects it:
///  - Android: straight into the public Downloads folder (visible in the
///    Files app / notification tray) via [FileDownloader], which is backed
///    by Android's own DownloadManager.
///  - iOS/other: [FileDownloader] doesn't support these platforms, so we
///    fall back to opening the file externally — the user can save it via
///    the share sheet from there (the idiomatic iOS flow).
Future<void> downloadDocument(BuildContext context, {required String url, required String title}) async {
  if (Platform.isAndroid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $title…'), duration: const Duration(seconds: 2)),
    );
    await FileDownloader.downloadFile(
      url: url,
      name: _fileNameFrom(url, title),
      onDownloadCompleted: (path) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to Downloads: $title')),
        );
      },
      onDownloadError: (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $error')),
        );
      },
    );
  } else {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

String _fileNameFrom(String url, String title) {
  final ext = url.contains('.') ? url.split('.').last : 'pdf';
  final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  if (safeTitle.isEmpty) {
    final segments = Uri.parse(url).pathSegments;
    return segments.isNotEmpty ? segments.last : 'document.$ext';
  }
  return '$safeTitle.$ext';
}
