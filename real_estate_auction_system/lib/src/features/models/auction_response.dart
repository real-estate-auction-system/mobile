class AuctionResponse {
  final bool onGoing;
  final double currentPrice;
  final DateTime endTime;
  final double userBind;
  AuctionResponse({
    required this.onGoing,
    required this.currentPrice,
    required this.endTime,
    required this.userBind,
  });

  factory AuctionResponse.fromJson(Map<String, dynamic> json) {
    return AuctionResponse(
      onGoing: json['onGoing'] as bool,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      endTime: DateTime.parse(json['endtime'] as String),
      userBind: (json['userBind'] as num).toDouble(),
    );
  }
}
