import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final String titleString;
  final VoidCallback? onPressedCallback;
  final bool? isLogout;

  const Box({
    super.key,
    required this.titleString,
    this.onPressedCallback,
    this.isLogout
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: SizedBox(
      width: screenWidth,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressedCallback,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                titleString,
                style: TextStyle(
                  color: isLogout == true ? Colors.red : Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
