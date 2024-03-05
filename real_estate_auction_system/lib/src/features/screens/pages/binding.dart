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
  TextEditingController autoBindingController = TextEditingController();
  bool isAutomatically = false;
  late IOWebSocketChannel _channel;
  double currentPrice = 0.0;
  double myCurrentBind = 0.0;
  int time = 30;
  Timer? _timer;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('wss://10.0.2.2:5001/auction-hub');

    _channel.sink.add('{"protocol":"json","version":1}');

    _channel.stream.listen((message) {
      double newPrice = extractSecondDoubleFromMessage(message);
      int newTime = extractFirstIntFromMessage(message);
      time = newTime;
      setState(() {
        currentPrice = newPrice;
        if (myCurrentBind < currentPrice && _isChecked == true) {
          double? higherMoney;
          if (autoBindingController.text != "") {
            higherMoney = double.parse(priceController.text);
          } else {
            higherMoney = 1000000;
          }
          myCurrentBind = currentPrice + higherMoney;
          auction(context, widget.realEstate.id, myCurrentBind);
        }
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
    return 0.0;
  }

  int extractFirstIntFromMessage(String message) {
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
                'My Current Bind: ${myCurrentBind.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              Text(
                'Current Price: ${currentPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              Text(
                'Current Time: ${time.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              const SizedBox(height: 20),
              numberInputWidget(context, priceController, 'Enter price'),
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
                      myCurrentBind = double.parse(priceController.text);
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
              ),
              SizedBox(
                height: 50, // Adjust the height as needed
                child: Row(
                  children: [
                    Expanded(
                      child: numberInputWidget(
                          context, autoBindingController, 'Higher money'),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Binding Automatically'),
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget numberInputWidget(BuildContext context, controller, String text) {
  return TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    ],
    decoration: InputDecoration(
      labelText: text,
      hintText: '0.00',
      border: const OutlineInputBorder(),
    ),
  );
}
