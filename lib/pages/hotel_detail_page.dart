import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 酒店详情页面（临时占位符）
class HotelDetailPage extends StatelessWidget {
  final int hotelId;

  const HotelDetailPage({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 64),
            const SizedBox(height: 16),
            Text(
              'Hotel Detail Page',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Hotel ID: $hotelId'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
