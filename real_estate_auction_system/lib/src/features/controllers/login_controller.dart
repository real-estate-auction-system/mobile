import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate_auction_system/src/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:real_estate_auction_system/src/features/models/jwt_token_response.dart';
import 'package:real_estate_auction_system/src/features/widgets/alert_dialog.dart';
import 'package:real_estate_auction_system/src/features/screens/main-pages/main_pages.dart';

late Box box1;
Future loginFuture(BuildContext context, String userName, String password,
    bool rememberUser) async {
  showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: mainColor,
            backgroundColor: greyColor,
          ),
        );
      });
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Account/Login');
    final headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      "userName": userName,
      "password": password,
    };
    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic apiResponse = json.decode(response.body);
      JWTTokenResponse jwtResponse = JWTTokenResponse.fromJson(apiResponse);
      var sharedPref = await SharedPreferences.getInstance();
      sharedPref.setString('token', jwtResponse.token);
      if (jwtResponse.role == 2) {
        if (rememberUser) {
          box1 = await Hive.openBox('logindata');
          box1.put('userName', userName);
          box1.put('password', password);
        }
        if (!context.mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPages(index: 0)),
        );
      } else {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        CustomAlertDialog.show(
          context,
          "Lỗi đăng nhập",
          "Chỉ khách hàng mới đăng nhập được vào app này!",
        );
      }
    } else {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      CustomAlertDialog.show(
        context,
        "Đăng nhập không thành công",
        response.body,
      );
    }
  } catch (error) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    CustomAlertDialog.show(
      context,
      "Đăng nhập không thành công",
      "Có lỗi xảy ra trong quá trình đăng nhập, vui lòng thử lại sau",
    );
  }
}
