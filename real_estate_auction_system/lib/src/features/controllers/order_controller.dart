import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/api_config.dart';
import 'package:real_estate_auction_system/src/features/models/order.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:real_estate_auction_system/src/features/widgets/alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Order>> getOrders(BuildContext context) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/orders/AccountId');
  var sharedPref = await SharedPreferences.getInstance();
  String? token = sharedPref.getString('token');
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      List<dynamic> apiResponse = json.decode(response.body);
    List<Order> order = Order.listFromJson(apiResponse);
      return order;
    } else {
      return [];
    }
  } catch (error) {
    if (!context.mounted) return [];
    Navigator.of(context).pop();
    CustomAlertDialog.show(
      context,
      "Đã xảy ra lỗi",
      "Có lỗi xảy ra trong quá trình nhận dữ liệu, vui lòng thử lại sau",
    );
    return [];
  }
}