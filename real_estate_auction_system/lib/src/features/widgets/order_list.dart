import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/models/order.dart';

class OrderListPage extends StatelessWidget {
  final Order order;

  const OrderListPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ListTile(
          title: Text(order.name),
          subtitle: Text(order.price.toString()),
          onTap: () {},
        ));
  }
}
