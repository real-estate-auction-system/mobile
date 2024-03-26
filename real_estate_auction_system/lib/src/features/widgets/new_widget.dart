import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/models/news.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/news_detail.dart';

class NewsWidget extends StatelessWidget {
  final News newsItem;

  const NewsWidget({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ListTile(
            leading: Image.network(newsItem.image, fit: BoxFit.cover),
            title: Text(newsItem.title),
            subtitle: Text(newsItem.time.toString()),
            trailing: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewsDetailPage(news: newsItem)),
                );
              },
              child: const Icon(Icons.arrow_forward),
            )));
  }
}
