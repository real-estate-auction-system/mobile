import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,
       style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25
       ),),
      content: Text(content,
       style: const TextStyle(
        fontSize: 18
       ),),
      actions: <Widget>[
        TextButton(
          child: const Text("OK",
           style: TextStyle(
        color: mainColor,
        fontSize: 20
       ),),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }

  static void show(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: title,
          content: content,
        );
      },
    );
  }
}
