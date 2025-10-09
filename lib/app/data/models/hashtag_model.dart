class HashtagModel {
  int id;
  String name;
  int count;
  String? img;

  HashtagModel({
    required this.id,
    required this.name,
    required this.count,
    this.img,
  });

  factory HashtagModel.fromJson(Map<String, dynamic> json) {
    return HashtagModel(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      img: json['img'] == 'None' ? null : json['img'],
    );
  }
}
