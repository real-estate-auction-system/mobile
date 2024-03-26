import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/models/news.dart';

class NewsDetailPage extends StatelessWidget {
  final News news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(news.image, fit: BoxFit.cover),
            Text(
              news.title,
              style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              news.description,
              style:const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: ${news.time.toString()}',
              style:const TextStyle(fontSize: 16),
            ),
            // Add more details here if needed
          ],
        ),
      ),
    );
  }
}
