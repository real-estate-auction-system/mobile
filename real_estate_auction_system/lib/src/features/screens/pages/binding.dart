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
      double value = await extractFirstDoubleFromMessage(message);
      setState(() {
        _currentPrice = value;
        if (_userBind < _currentPrice && _isChecked == true) {
          double higherPrice = 1000000;
          if (autoBindingController.text != "") {
            higherPrice = double.parse(autoBindingController.text);
          }
          double sum = _currentPrice + higherPrice;
          auction(context, widget.realEstate.id, sum);

          _currentPrice = sum;
          _userBind = sum;
        }
        checkEndTime();
      });
    }
    );
  }

  void checkEndTime() {
  final now = DateTime.now();
  if (now.isAfter(widget.endTime)) {
    time = 0;
    _timer?.cancel();
    showAuctionEndedDialog(context);
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
          _timer?.cancel(); 
          showAuctionEndedDialog(context);
          Navigator.of(context).pop();

        }
      });
    });
  }
}

  void showAuctionEndedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text("Phiên đấu giá đã kết thúc"),
        content: Text("Cửa sổ này sẽ đóng trong 5 giây."),
      );
      
    },
  );
}

  @override
  void dispose() {
    _channel.sink.close();
    _timer?.cancel();
    super.dispose();
  }

  Future<double> extractFirstDoubleFromMessage(String message) async {
    String trimmedJsonString = message.substring(0, message.length - 1);

    Map<String, dynamic> json = await jsonDecode(trimmedJsonString);
    if (json['type'] == 1 && json['target'] == "AuctionCountdown") {
      List<dynamic> arguments = json['arguments'];
      if (arguments.isNotEmpty && arguments[0] is num) {
        double secondValue = (arguments[0] as num).toDouble();
        return secondValue;
      }
      return _currentPrice;
    }
    return _currentPrice;
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
              AuctionWinnerMessage(
                currentPrice: _currentPrice,
                userBind: _userBind,
              ),
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

class AuctionWinnerMessage extends StatefulWidget {
  final double currentPrice;
  final double userBind;

  const AuctionWinnerMessage({
    required this.currentPrice,
    required this.userBind,
    Key? key,
  }) : super(key: key);

  @override
  State<AuctionWinnerMessage> createState() => _AuctionWinnerMessageState();
}

class _AuctionWinnerMessageState extends State<AuctionWinnerMessage> {
  bool isWinner = false;

  @override
  void initState() {
    super.initState();
    checkWinnerStatus();
  }

  void checkWinnerStatus() {
    setState(() {
      isWinner = (widget.currentPrice == widget.userBind);
    });
  }

  @override
  void didUpdateWidget(covariant AuctionWinnerMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPrice != widget.currentPrice ||
        oldWidget.userBind != widget.userBind) {
      checkWinnerStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isWinner
        ? const Text('You are currently the winner.')
        : const SizedBox();
  }
}
