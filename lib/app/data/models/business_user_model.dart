class BusinessUserModel {
  final int id;
  final String businessName;
  final String businessPhone;
  final String backPhoto;
  final String description;
  final String? address;
  final String? tiktok;
  final String? instagram;
  final String? youtube;
  final String? website;
  final String? status;
  final String? popular;
  final String? created;
  final List<String>? images;

  final int title;
  final int user;
  final int? productCount;
  final int? userID;

  BusinessUserModel({
    required this.id,
    required this.backPhoto,
    required this.description,
    required this.businessName,
    required this.businessPhone,
    required this.title,
    required this.user,
    this.created,
    this.userID,
    this.address,
    this.popular,
    this.productCount,
    this.status,
    this.images,
    this.tiktok,
    this.instagram,
    this.youtube,
    this.website,
  });

  factory BusinessUserModel.fromJson(Map<String, dynamic> json) {
    return BusinessUserModel(
      id: json['id'] as int? ?? 0,
      userID: json['user_id'] ?? 0,
      businessName: json['businessName'] as String? ?? '',
      businessPhone: json['businessPhone'] as String? ?? json['phone'] ?? '',
      backPhoto: json['back_photo'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] ?? '',
      tiktok: json['tiktok'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
      website: json['website'] ?? '',
      created: json['created'].toString(),
      popular: json['popular'].toString(),
      status: json['status'].toString(),
      user: json['user'] ?? 0,
      productCount: json['productCount'] ?? 0,
      title: json['title'] ?? json['title_id'] ?? 0,
      images: (json['images'] as List<dynamic>?)?.map((image) => image['image'] as String).toList() ?? [], // Empty list if null
    );
  }
}

class GetMyStatusModel {
  int? id;
  String? businessName;
  String? businessPhone;
  String? backPhoto;
  String? description;
  String? address;
  String? tiktok;
  String? instagram;
  String? youtube;
  String? website;
  String? created;
  bool? popular;
  String? status;
  int? user;

  GetMyStatusModel({
    this.id,
    this.businessName,
    this.businessPhone,
    this.backPhoto,
    this.description,
    this.address,
    this.tiktok,
    this.instagram,
    this.youtube,
    this.website,
    this.created,
    this.popular,
    this.status,
    this.user,
  });

  factory GetMyStatusModel.fromJson(Map<String, dynamic> json) {
    return GetMyStatusModel(
      id: json['id'],
      businessName: json['businessName'],
      businessPhone: json['businessPhone'],
      backPhoto: json['back_photo'],
      description: json['description'],
      address: json['address'],
      tiktok: json['tiktok'],
      instagram: json['instagram'],
      youtube: json['youtube'],
      website: json['website'],
      created: json['created'],
      popular: json['popular'],
      status: json['status'],
      user: json['user'],
    );
  }
}
