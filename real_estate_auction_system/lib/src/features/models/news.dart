class News {
  final String name;
  final String title;
  final String description;
  final String image;
  final DateTime time;
  News({
    required this.name,
    required this.title,
    required this.description,
    required this.image,
    required this.time,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      name: json['name'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      time: DateTime.parse(json['time'] as String),
    );
  }
  static List<News> listFromJson(List<dynamic> jsonArray) {
    return jsonArray.map((json) => News.fromJson(json)).toList();
  }
}
