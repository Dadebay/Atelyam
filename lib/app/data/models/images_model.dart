class ImageModel {
  final int id;
  final List<String?> images;
  final int product;

  ImageModel({
    required this.id,
    required this.images,
    required this.product,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    final List<String?> images = [];

    for (var key in json.keys) {
      if (key.startsWith('img') && json[key] != null) {
        images.add(json[key]);
      } else {
        images.add(null);
      }
    }
    images.removeAt(0);
    images.removeAt(4);
    return ImageModel(
      id: json['id'],
      images: images,
      product: json['product'],
    );
  }
}
