import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/models/auction_response.dart';
import 'package:real_estate_auction_system/src/features/models/real_estate.dart';
import 'package:real_estate_auction_system/src/constants/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_auction_system/src/features/screens/pages/binding.dart';
import 'dart:convert';
import 'package:real_estate_auction_system/src/features/widgets/alert_dialog.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';

Future<List<RealEstate>> getTodayAuction(BuildContext context) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Auction/TodayAuction');
    final headers = {'Content-Type': 'application/json'};
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic apiResponse = json.decode(response.body);
      List<dynamic> realEstateJsonList = apiResponse['realEstates'];
      List<RealEstate> realEstate = RealEstate.listFromJson(realEstateJsonList);
      return realEstate;
    } else {
      if (!context.mounted) return [];
      Navigator.of(context).pop();
      CustomAlertDialog.show(
        context,
        "Đã xảy ra lỗi",
        response.body,
      );
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

Future<double> fetchDoubleFromWebSocket() async {
  Completer<double> completer = Completer<double>();
  final url = Uri.parse('wss://10.0.2.2:5001/auction-hub');
  final channel = IOWebSocketChannel.connect(url);

  StreamSubscription? subscription;
  Timer? timer;

  subscription = channel.stream.listen((message) {
    try {
      Map<String, dynamic> json = jsonDecode(message);
      if (json['type'] == 1 && json['target'] == 'BidPlaced') {
        double value = (json['arguments'] as List<dynamic>).last.toDouble();
        completer.complete(value);
        subscription?.cancel();
        timer?.cancel();
        channel.sink.close();
      }
    } catch (e) {
      completer.completeError('Error parsing message: $e');
    }
  });

  const Duration timeoutDuration = Duration(seconds: 60);
  timer = Timer(timeoutDuration, () {
    if (!completer.isCompleted) {
      completer.completeError('Timeout: No response received');
      subscription?.cancel();
      channel.sink.close();
    }
  });

  return completer.future;
}

Future auction(BuildContext context, int auctionId, double currentPrice) async {
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
  final uri = Uri.parse(
      '${ApiConfig.baseUrl}/RealtimeAuction?realEstateId=$auctionId&currentPrice=$currentPrice');
  var sharedPref = await SharedPreferences.getInstance();
  String? token = sharedPref.getString('token');
  await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 30));
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();
}

Future<void> checkAuction(
    BuildContext context, int auctionId, RealEstate realEstate) async {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: mainColor,
          backgroundColor: greyColor,
        ),
      );
    },
  );

  final uri = Uri.parse(
      '${ApiConfig.baseUrl}/RealtimeAuction/StartAuction?realEstateId=$auctionId');
  var sharedPref = await SharedPreferences.getInstance();
  String? token = sharedPref.getString('token');
   final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 30));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final auctionResponse = AuctionResponse.fromJson(jsonResponse);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (auctionResponse.onGoing) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Binding(
              currentPrice: auctionResponse.currentPrice,
              endTime: auctionResponse.endTime,
              realEstate: realEstate,
              userBind: auctionResponse.userBind),
        ),
      );
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Phiên đấu giá đã kết thúc"),
            content: const Text(
                "Hãy quét lại trang để load lại thông tin các buổi đấu giá."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  } else {}
}
