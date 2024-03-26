class Order {
  final DateTime orderDate;
  final double price;
  final String code;
  final String name;
  Order({
    required this.orderDate,
    required this.price,
    required this.code,
    required this.name,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderDate: DateTime.parse(json['orderDate'] as String),
      price: (json['price'] as num).toDouble(),
      code: json['realEstate']['code'],
      name: json['realEstate']['name'],
    );
  }
  static List<Order> listFromJson(List<dynamic> jsonArray) {
    return jsonArray.map((json) => Order.fromJson(json)).toList();
  }
}
