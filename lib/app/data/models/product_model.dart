class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String img;
  final String? status;
  final String created;
  final int user;
  final int viewCount;
  final int category;
  final int hashtag;

  ProductModel({
    required this.id,
    required this.viewCount,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
    required this.created,
    required this.user,
    required this.category,
    required this.hashtag,
    this.status,
  });

  // JSON'dan ProductModel oluşturma
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'].toString(),
      description: json['description'].toString(),
      price: json['price'].toString(),
      img: json['img'].toString(),
      created: json['created'].toString(),
      viewCount: json['viewcount'] ?? 0,
      status: json['pending'].toString(),
      user: json['user'] ?? 0,
      category: json['category'] ?? 0,
      hashtag: json['hashtag'] ?? 0,
    );
  }

  // ProductModel'i JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
      'img': img,
      'created': created,
      'user': user,
      'category': category,
      'hashtag': hashtag,
      'viewcount': viewCount,
    };
  }
}
