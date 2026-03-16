import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionCh;
  final String? descriptionUz;
  final String? descriptionTr;
  final String? priceEn;
  final String? priceRu;
  final String? priceCh;
  final String? priceUz;
  final String? priceTr;
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
    this.descriptionEn,
    this.descriptionRu,
    this.descriptionCh,
    this.descriptionUz,
    this.descriptionTr,
    this.priceEn,
    this.priceRu,
    this.priceCh,
    this.priceUz,
    this.priceTr,
  });

  /// Uygulama diline göre doğru açıklamayı döndürür
  String get localizedDescription {
    final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
    switch (langCode) {
      case 'en':
        return descriptionEn?.isNotEmpty == true ? descriptionEn! : description;
      case 'ru':
        return descriptionRu?.isNotEmpty == true ? descriptionRu! : description;
      case 'ch':
        return descriptionCh?.isNotEmpty == true ? descriptionCh! : description;
      case 'uz':
        return descriptionUz?.isNotEmpty == true ? descriptionUz! : description;
      case 'tr':
        return descriptionTr?.isNotEmpty == true ? descriptionTr! : description;
      default:
        return description;
    }
  }

  /// Uygulama diline göre doğru fiyatı döndürür
  String get localizedPrice {
    final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
    switch (langCode) {
      case 'en':
        return priceEn?.isNotEmpty == true ? priceEn! : price;
      case 'ru':
        return priceRu?.isNotEmpty == true ? priceRu! : price;
      case 'ch':
        return priceCh?.isNotEmpty == true ? priceCh! : price;
      case 'uz':
        return priceUz?.isNotEmpty == true ? priceUz! : price;
      case 'tr':
        return priceTr?.isNotEmpty == true ? priceTr! : price;
      default:
        return price;
    }
  }

  // JSON'dan ProductModel oluşturma
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'].toString(),
      description: json['description'].toString(),
      price: json['price'].toString(),
      descriptionEn: json['description_en'] as String?,
      descriptionRu: json['description_ru'] as String?,
      descriptionCh: json['description_ch'] as String?,
      descriptionUz: json['description_uz'] as String?,
      descriptionTr: json['description_tr'] as String?,
      priceEn: json['price_en'] as String?,
      priceRu: json['price_ru'] as String?,
      priceCh: json['price_ch'] as String?,
      priceUz: json['price_uz'] as String?,
      priceTr: json['price_tr'] as String?,
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
      'description_en': descriptionEn,
      'description_ru': descriptionRu,
      'description_ch': descriptionCh,
      'description_uz': descriptionUz,
      'description_tr': descriptionTr,
      'price_en': priceEn,
      'price_ru': priceRu,
      'price_ch': priceCh,
      'price_uz': priceUz,
      'price_tr': priceTr,
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
