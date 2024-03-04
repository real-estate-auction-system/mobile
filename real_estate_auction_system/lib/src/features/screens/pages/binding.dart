import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_auction_system/src/features/controllers/auction_controller.dart';
import 'package:real_estate_auction_system/src/features/models/real_estate.dart';
import 'package:web_socket_channel/io.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'dart:async';

class Binding extends StatefulWidget {
  final RealEstate realEstate;

  const Binding({Key? key, required this.realEstate}) : super(key: key);

  @override
  State<Binding> createState() => _BindingPageState();
}

class _BindingPageState extends State<Binding> {
  TextEditingController priceController = TextEditingController();
  bool isAutomatically = false;
  late IOWebSocketChannel _channel;
  double currentPrice = 0.0;
  int time = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('wss://10.0.2.2:5001/auction-hub');

    _channel.sink.add('{"protocol":"json","version":1}');

    _channel.stream.listen((message) {
      double newPrice = extractSecondDoubleFromMessage(message);
      int newTime = extractFirstIntFromMessage(message);
      setState(() {
        currentPrice = newPrice;
        time = newTime;
        if (time == 0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Phiên đấu giá đã kết thúc"),
                content: const Text("Cửa sổ đấu giá sẽ đóng sau 5 giây."),
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
          if (!context.mounted) return;
          _timer = Timer(const Duration(seconds: 5), () {
            Navigator.of(context).pop();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _timer?.cancel();
    super.dispose();
  }

  double extractSecondDoubleFromMessage(String message) {
    try {
      String trimmedJsonString = message.substring(0, message.length - 1);

      Map<String, dynamic> json = jsonDecode(trimmedJsonString);
      if (json['type'] == 1 && json['target'] == "AuctionCountdown") {
        List<dynamic> arguments = json['arguments'];
        if (arguments.length >= 2) {
          double secondValue = (arguments[1] as num).toDouble();
          return secondValue;
        }
      } else {
        return currentPrice;
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
    return 0.0;
  }

  int extractFirstIntFromMessage(String message) {
    try {
      String trimmedJsonString = message.substring(0, message.length - 1);
      Map<String, dynamic> json = jsonDecode(trimmedJsonString);
      if (json['type'] == 1 && json['target'] == "AuctionCountdown") {
        List<dynamic> arguments = json['arguments'];
        if (arguments.length >= 2) {
          int firstValue = (arguments[0] as num).toInt();
          return firstValue;
        }
      } else {
        if (json['target'] == "AuctionEnded") {
          return 0;
        }
        return time;
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.realEstate.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Current Price: ${currentPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              Text(
                'Current Time: ${time.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              const SizedBox(height: 20),
              NumberInputWidget(controller: priceController),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (priceController.text == "" ||
                        double.parse(priceController.text) <= currentPrice) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Số tiền không đúng quy định"),
                            content: const Text(
                                "Vui lòng nhập số tiền lớn hơn giá hiện tại!"),
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
                    } else {
                      auction(context, widget.realEstate.id,
                          double.parse(priceController.text));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Đấu giá',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NumberInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const NumberInputWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      decoration: const InputDecoration(
        labelText: 'Enter Price',
        hintText: '0.00',
        border: OutlineInputBorder(),
      ),
    );
  }
}
