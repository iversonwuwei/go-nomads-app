import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class ShareCardGenerator {
  final ScreenshotController _screenshotController = ScreenshotController();

  Widget buildShareCard({
    required String title,
    required String description,
    required String url,
    String? imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(url, style: const TextStyle(color: Colors.blue, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> generateShareCardImage({
    required String title,
    required String description,
    required String url,
    String? imageUrl,
  }) async {
    final widget = buildShareCard(title: title, description: description, url: url, imageUrl: imageUrl);
    return await _screenshotController.captureFromWidget(widget);
  }
}
