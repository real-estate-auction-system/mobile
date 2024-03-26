import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/models/news.dart';
import 'package:real_estate_auction_system/src/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:real_estate_auction_system/src/features/widgets/alert_dialog.dart';
import 'dart:async';

Future<List<News>> getNews(BuildContext context, int pageIndex, int pageSize) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/News/Pagination?pageIndex=$pageIndex&pageSize=$pageSize');
    final headers = {'Content-Type': 'application/json'};
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic apiResponse = json.decode(response.body);
      List<dynamic> realEstateJsonList = apiResponse['items'];
      List<News> news = News.listFromJson(realEstateJsonList);
      return news;
    } else {
      return [];
    }
  } catch (error) {
    if (!context.mounted) return [];
    Navigator.of(context).pop();
    CustomAlertDialog.show(
      context,
      "Đã xảy ra lỗi",
      "Có lỗi xảy ra trong quá trình đăng nhập, vui lòng thử lại sau",
    );
    return [];
  }
}