import 'package:real_estate_auction_system/src/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_auction_system/src/features/models/user.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> getUserDetail() async {
  {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String? token = sharedPref.getString('token');
      final uri = Uri.parse('${ApiConfig.baseUrl}/Account/GetAccountById/profile');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}