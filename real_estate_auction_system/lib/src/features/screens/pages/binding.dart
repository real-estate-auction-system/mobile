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
  final double currentPrice;
  final DateTime endTime;
  final double userBind;
  const Binding(
      {Key? key,
      required this.realEstate,
      required this.currentPrice,
      required this.endTime,
      required this.userBind})
      : super(key: key);

  @override
  State<Binding> createState() => _BindingPageState();
}

class _BindingPageState extends State<Binding> {
  TextEditingController priceController = TextEditingController();
  TextEditingController autoBindingController = TextEditingController();
  late IOWebSocketChannel _channel;
  double _userBind = 0.0;
  Timer? _timer;
  bool _isChecked = false;
  int time = 3600;
  double _currentPrice = 0.0;
  @override
  void initState() {
    super.initState();
    _userBind = widget.userBind;
    _currentPrice = widget.currentPrice;
    _channel = IOWebSocketChannel.connect('wss://10.0.2.2:5001/auction-hub');

    _channel.sink.add('{"protocol":"json","version":1}');

    _channel.stream.listen((message) async {
      await extractFirstDoubleFromMessage(message);
      setState(() {
        if (DateTime.now().isAfter(widget.endTime)) {
          time = 0;
          _timer?.cancel(); // Stop the timer if the auction ended
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
        } else {
          if (_timer != null) {
            _timer?.cancel();
          }
          _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
            setState(() {
              final now = DateTime.now();
              if (widget.endTime.isAfter(now)) {
                time = widget.endTime.difference(now).inSeconds;
              } else {
                time = 0;
                _timer?.cancel(); // Stop the timer if the auction ended
              }
            });
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

  Future<void> extractFirstDoubleFromMessage(String message) async {
    String trimmedJsonString = message.substring(0, message.length - 1);

    Map<String, dynamic> json = await jsonDecode(trimmedJsonString);
    if (json['type'] == 1 && json['target'] == "AuctionCountdown") {
      List<dynamic> arguments = json['arguments'];
      if (arguments.isNotEmpty && arguments[0] is num) {
        double secondValue = (arguments[0] as num).toDouble();
        setState(() {
          _currentPrice = secondValue;
        });
      }
    }
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
                'My Current Bind: ${_userBind.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              Text(
                'Current Price: ${_currentPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              Text(
                'Time left: ${formatTime(time)}', // Display the remaining time
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
              ),
              if (_currentPrice == _userBind)
                const Text('You are currently the winner.'),
              const SizedBox(height: 20),
              numberInputWidget(context, priceController, 'Enter price'),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (priceController.text == "" ||
                        double.parse(priceController.text) <=
                            widget.currentPrice) {
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
                      _userBind = double.parse(priceController.text);
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

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$remainingSeconds';
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
