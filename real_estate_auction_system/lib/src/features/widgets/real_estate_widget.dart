import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/images.dart';
import 'package:real_estate_auction_system/src/features/models/real_estate.dart';
import 'package:real_estate_auction_system/src/features/screens/pages/binding.dart';

class RealEstateWidget extends StatelessWidget {
  final RealEstate realEstate;

  const RealEstateWidget({Key? key, required this.realEstate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: realEstate.imageURL != null && realEstate.imageURL!.isNotEmpty
          ? Image.network(
              realEstate.imageURL!,
              fit: BoxFit.cover,
            )
          : const Image(
              image: AssetImage(logo),
            ),
      title: Text(realEstate.name),
      subtitle: Text(realEstate.address),
      trailing: Text('\$${realEstate.startPrice.toString()}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Binding(realEstate: realEstate),
          ),
        );
      },
    );
  }
}
