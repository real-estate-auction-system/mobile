import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/features/controllers/auction_controller.dart';
import 'package:real_estate_auction_system/src/features/models/real_estate.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/features/widgets/real_estate_widget.dart';

class Auction extends StatefulWidget {
  const Auction({super.key});
  @override
  State<Auction> createState() => _AuctionState();
}

class _AuctionState extends State<Auction> {
  late List<RealEstate> realEstates;
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
    List<RealEstate> fetchedData = await getTodayAuction(context);
    setState(() {
      realEstates = fetchedData;
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
            'Đấu giá',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () => initializeData(),
            backgroundColor: greyColor,
            color: mainColor,
            child: FutureBuilder(
                future: null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _loading) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 200),
                        Center(
                          child: CircularProgressIndicator(
                            color: mainColor,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  } else {
                    return SizedBox(
                        child: ListView.builder(
                      itemCount: realEstates.length,
                      itemBuilder: (context, index) {
                        return RealEstateWidget(realEstate: realEstates[index]);
                      },
                    ));
                  }
                })));
  }
}
