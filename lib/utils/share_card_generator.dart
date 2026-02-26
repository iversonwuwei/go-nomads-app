import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShareCardGenerator {
  final ScreenshotController _screenshotController = ScreenshotController();

  Widget buildShareCard({
    required String title,
    required String description,
    required String url,
    String? imageUrl,
  }) {
    return Card(
      margin: EdgeInsets.all(16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(imageUrl, height: 120.h, width: double.infinity, fit: BoxFit.cover),
              ),
            SizedBox(height: 12.h),
            Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(description, style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(url, style: TextStyle(color: Colors.blue, fontSize: 14.sp)),
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
