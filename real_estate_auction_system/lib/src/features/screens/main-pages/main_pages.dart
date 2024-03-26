import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/auction.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/news.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/order.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/setting.dart';

class MainPages extends StatefulWidget {
  final int index;

  const MainPages({super.key, required this.index});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_sharp),
            label: 'Auction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
        activeColor: mainColor,
        inactiveColor: Colors.black,
        border: const Border(
          top: BorderSide(color: Colors.black),
        ),
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) {
                return const SafeArea(
                  child: CupertinoPageScaffold(child: Auction()),
                );
              },
            );
          case 1:
            return CupertinoTabView(
              builder: (context) {
                return const SafeArea(
                  child: CupertinoPageScaffold(child: OrderPage()),
                );
              },
            );
          case 2:
            return CupertinoTabView(
              builder: (context) {
                return const SafeArea(
                  child: CupertinoPageScaffold(child: NewsPage()),
                );
              },
            );
          case 3:
            return CupertinoTabView(
              builder: (context) {
                return const SafeArea(
                  child: CupertinoPageScaffold(child: Setting()),
                );
              },
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
