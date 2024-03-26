import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/controllers/order_controller.dart';
import 'package:real_estate_auction_system/src/features/models/order.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/features/widgets/order_list.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> orders = [];
  late bool _loading;
@override
  void initState() {
    initializeData();
    super.initState();
  }

  Future<void> initializeData() async {
    setState(() {
      _loading = true;
    });
    List<Order> fetchedData = await getOrders(context);
    setState(() {
      orders = fetchedData;
      _loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Đất đã thắng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      body: RefreshIndicator(
        onRefresh: initializeData,
        backgroundColor: greyColor,
        color: mainColor,
        child: _loading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: CircularProgressIndicator(
                      color: mainColor,
                    ),
                  ),
                ],
              )
            : orders.isEmpty
                ? const Center(
                    child: Text('Bạn chưa mua được sản phẩm nào'),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderListPage(
                        order: orders[index],
                      );
                    },
                  ),
      ),
    );
  }
}
