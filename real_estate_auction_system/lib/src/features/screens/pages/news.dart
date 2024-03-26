import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/controllers/news_controller.dart';
import 'package:real_estate_auction_system/src/features/models/news.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/features/widgets/new_widget.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<News> _news = [];
  late bool _loading;
  int pageIndex = 0;
  int pageSize = 10;
  @override
  void initState() {
    initializeData();
    super.initState();
  }

  Future<void> initializeData() async {
    setState(() {
      _loading = true;
    });
    List<News> fetchedData = await getNews(context, pageIndex, pageSize);
    setState(() {
      _news = fetchedData;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Tin tức',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: initializeData,
        backgroundColor: greyColor,
        color: mainColor,
        child: _loading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: CircularProgressIndicator(
                      color: mainColor,
                    ),
                  ),
                ],
              )
            : _news.isEmpty
                ? const Center(
                    child: Text('Không có tin tức nào'),
                  )
                : ListView.builder(
                    itemCount: _news.length,
                    itemBuilder: (context, index) {
                      return NewsWidget(
                        newsItem: _news[index],
                      );
                    },
                  ),
      ),
    );
  }
}
