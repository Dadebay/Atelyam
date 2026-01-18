import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class VirtualTryOnService {
  final Dio _dio = Dio();

  // Google Gemini API Key - AI Studio'dan aldığınız key
  static const String _geminiApiKey = 'AIzaSyCNrlZB7mdyREpqhMHpBd0tqXRAxW2airw';

  // Gemini 2.0 Flash Model (Görüntü analizi için)
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  /// Google Gemini ile sanal giyim deneme
  /// ⚠️ NOT: Gemini görüntü üretimi yapamaz, sadece analiz ve tavsiye verir
  Future<String?> tryOnClothing({
    required String garmentImagePath,
    required String personImagePath,
  }) async {
    try {
      debugPrint('🎨 Google Gemini kullanılıyor...');

      return await _analyzeWithGemini(
        garmentImagePath: garmentImagePath,
        personImagePath: personImagePath,
      );
    } catch (e) {
      debugPrint('❌ Virtual Try-On Error: $e');
      throw Exception('Sanal deneme başarısız: ${e.toString()}');
    }
  }

  /// Google Gemini ile görüntü analizi
  /// ⚠️ ÖNEMLİ: Gemini görüntü ÜRETEMEZ, sadece analiz yapar!
  /// Virtual try-on için görüntü üretimi gerekir, bu yüzden bu yöntem çalışmaz.
  Future<String?> _analyzeWithGemini({
    required String garmentImagePath,
    required String personImagePath,
  }) async {
    try {
      // Resimleri base64'e çevir
      final garmentBytes = await File(garmentImagePath).readAsBytes();
      final personBytes = await File(personImagePath).readAsBytes();
      final garmentBase64 = base64Encode(garmentBytes);
      final personBase64 = base64Encode(personBytes);

      debugPrint('📤 Gemini API\'ye istek gönderiliyor...');

      // Gemini 2.0 Flash - Multimodal analiz
      final response = await _dio.post(
        '$_geminiApiUrl?key=$_geminiApiKey',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Analyze these two images: the first is a clothing item, the second is a person. Describe how the clothing would look on this person. Consider fit, style compatibility, and overall appearance.'
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': garmentBase64,
                  }
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': personBase64,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 1000,
          }
        },
      );

      if (response.statusCode == 200) {
        final candidates = response.data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'];
          debugPrint('✅ Gemini yanıtı: $text');

          // ⚠️ Gemini sadece TEXT döndürür, görüntü üretemez!
          // Bu nedenle orijinal person image'ı döndürüyoruz
          return personImagePath;
        }
      }

      throw Exception('Gemini: Yanıt alınamadı');
    } catch (e) {
      debugPrint('❌ Gemini Error: $e');

      if (e is DioException) {
        if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
          throw Exception('API key geçersiz veya eksik');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Gemini API endpoint bulunamadı');
        }
        throw Exception('API hatası: ${e.response?.statusCode}');
      }

      rethrow;
    }
  }
}
