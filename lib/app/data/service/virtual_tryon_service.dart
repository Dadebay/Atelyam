import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class VirtualTryOnService {
  final Dio _dio = Dio();
  
  // Replicate API anahtarınızı buraya ekleyin
  // https://replicate.com/account/api-tokens adresinden alabilirsiniz
  static const String _replicateApiKey = 'YOUR_REPLICATE_API_KEY_HERE';
  static const String _replicateBaseUrl = 'https://api.replicate.com/v1';
  
  // IDM-VTON model versiyonu
  static const String _modelVersion = 'yisol/idm-vton:c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3ff4';

  /// Sanal giyim deneme işlemini başlatır
  /// [garmentImagePath] - Kıyafet resmi yolu
  /// [personImagePath] - Kullanıcının resmi yolu
  /// Returns - Sonuç resmin URL'si
  Future<String?> tryOnClothing({
    required String garmentImagePath,
    required String personImagePath,
  }) async {
    try {
      // 1. Resimleri base64'e çevir
      final garmentBase64 = await _imageToBase64(garmentImagePath);
      final personBase64 = await _imageToBase64(personImagePath);

      // 2. Replicate API'ye prediction isteği gönder
      final predictionId = await _createPrediction(
        garmentImageUrl: garmentBase64,
        personImageUrl: personBase64,
      );

      if (predictionId == null) {
        throw Exception('Prediction oluşturulamadı');
      }

      // 3. Sonucu bekle ve al
      final resultUrl = await _waitForPrediction(predictionId);
      
      return resultUrl;
    } catch (e) {
      debugPrint('Virtual Try-On Error: $e');
      rethrow;
    }
  }

  /// Resmi base64 formatına çevirir
  Future<String> _imageToBase64(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Data URI formatında döndür
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      debugPrint('Image to Base64 Error: $e');
      rethrow;
    }
  }

  /// Replicate API'de prediction oluşturur
  Future<String?> _createPrediction({
    required String garmentImageUrl,
    required String personImageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '$_replicateBaseUrl/predictions',
        options: Options(
          headers: {
            'Authorization': 'Token $_replicateApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'version': _modelVersion.split(':')[1],
          'input': {
            'human_img': personImageUrl,
            'garm_img': garmentImageUrl,
            'garment_des': 'clothing item', // Kıyafet açıklaması
            'is_checked': true,
            'is_checked_crop': false,
            'denoise_steps': 30,
            'seed': 42,
          },
        },
      );

      if (response.statusCode == 201) {
        return response.data['id'];
      }
      
      return null;
    } catch (e) {
      debugPrint('Create Prediction Error: $e');
      return null;
    }
  }

  /// Prediction sonucunu bekler ve URL'i döndürür
  Future<String?> _waitForPrediction(String predictionId) async {
    try {
      // Maksimum 60 saniye bekle (2 saniye aralıklarla 30 kez)
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        
        final response = await _dio.get(
          '$_replicateBaseUrl/predictions/$predictionId',
          options: Options(
            headers: {
              'Authorization': 'Token $_replicateApiKey',
            },
          ),
        );

        if (response.statusCode == 200) {
          final status = response.data['status'];
          
          if (status == 'succeeded') {
            // Sonuç resmi URL'ini döndür
            final output = response.data['output'];
            if (output != null && output is List && output.isNotEmpty) {
              return output[0];
            } else if (output != null && output is String) {
              return output;
            }
            return null;
          } else if (status == 'failed' || status == 'canceled') {
            throw Exception('Prediction başarısız: $status');
          }
          // Hala işleniyor, döngüye devam et
        }
      }
      
      // Timeout
      throw Exception('Prediction timeout - 60 saniye içinde tamamlanamadı');
    } catch (e) {
      debugPrint('Wait for Prediction Error: $e');
      rethrow;
    }
  }

  /// Alternatif: Hugging Face Inference API kullanımı
  /// Ücretsiz ama daha yavaş olabilir
  Future<String?> tryOnWithHuggingFace({
    required String garmentImagePath,
    required String personImagePath,
  }) async {
    // Hugging Face implementation buraya eklenebilir
    // https://huggingface.co/spaces/yisol/IDM-VTON
    throw UnimplementedError('Hugging Face integration henüz eklenmedi');
  }
}
