class RealEstate {
  final String code;
  final String name;
  final double startPrice;
  final double acreage;
  final String address;
  final String? imageURL;
  final int id;
  RealEstate(
      {required this.code,
      required this.name,
      required this.startPrice,
      required this.acreage,
      required this.address,
      this.imageURL,
      required this.id});

  factory RealEstate.fromJson(Map<String, dynamic> json) {
    return RealEstate(
      code: json['code'],
      name: json['name'],
      startPrice: (json['startPrice'] as num).toDouble(),
      acreage: (json['acreage'] as num).toDouble(),
      address: json['address'],
      imageURL: json['imageURL'],
      id: json['id'],
    );
  }
  static List<RealEstate> listFromJson(List<dynamic> jsonArray) {
    return jsonArray.map((json) => RealEstate.fromJson(json)).toList();
  }
}
