import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({super.key});
  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is order page'),
      ),
      body:const  Center(
        child: null
      ),
    );
  }
}
