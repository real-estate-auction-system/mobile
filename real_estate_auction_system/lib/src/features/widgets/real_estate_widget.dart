import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/images.dart';
import 'package:real_estate_auction_system/src/features/controllers/auction_controller.dart';
import 'package:real_estate_auction_system/src/features/models/real_estate.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/binding.dart';

class RealEstateWidget extends StatelessWidget {
  final RealEstate realEstate;

  const RealEstateWidget({Key? key, required this.realEstate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ListTile(
            leading: _buildLeadingImage(),
            title: Text(realEstate.name),
            subtitle: Text(realEstate.address),
            onTap: () {},
            trailing: realEstate.realEstateStatus == 2
                ? SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool check = await checkAuction(context, realEstate.id);
                        if (check == true) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Binding(realEstate: realEstate),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Phiên đấu giá đã kết thúc"),
                                content: const Text(
                                    "Hãy quét lại trang để load lại thông tin các buổi đấu giá."),
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
                        }
                      },
                      child: const Text('Tới đấu giá'),
                    ),
                  )
                : realEstate.realEstateStatus == 1
                    ? const Text(
                        "Chưa diễn ra",
                        style: TextStyle(color: Colors.grey),
                      )
                    : const Text("Đã hoàn thành")));
  }

  Widget _buildLeadingImage() {
    return realEstate.imageURL != null && realEstate.imageURL!.isNotEmpty
        ? Image.network(
            realEstate.imageURL!,
            fit: BoxFit.cover,
          )
        : const Image(
            image: AssetImage(logo),
          );
  }
}
