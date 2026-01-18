import 'dart:io';
import 'package:atelyam/app/data/service/virtual_tryon_service.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class VirtualTryOnController extends GetxController {
  final VirtualTryOnService _tryOnService = VirtualTryOnService();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable değişkenler
  final RxBool isLoading = false.obs;
  final RxBool hasResult = false.obs;
  final RxString resultImageUrl = ''.obs;
  final RxString selectedPersonImage = ''.obs;
  final RxString garmentImageUrl = ''.obs;

  /// Kullanıcı resmini seçme
  Future<void> pickPersonImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedPersonImage.value = image.path;
        hasResult.value = false; // Önceki sonucu temizle
      }
    } catch (e) {
      showSnackBar('Hata', 'Resim seçilemedi: $e', ColorConstants.redColor);
    }
  }

  /// Kamera ile resim çekme
  Future<void> takePersonPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedPersonImage.value = image.path;
        hasResult.value = false;
      }
    } catch (e) {
      showSnackBar('Hata', 'Fotoğraf çekilemedi: $e', ColorConstants.redColor);
    }
  }

  /// Sanal giyim deneme işlemini başlat
  Future<void> startTryOn() async {
    if (selectedPersonImage.value.isEmpty) {
      showSnackBar('Uyarı', 'Lütfen önce bir fotoğraf seçin', ColorConstants.redColor);
      return;
    }

    if (garmentImageUrl.value.isEmpty) {
      showSnackBar('Uyarı', 'Kıyafet resmi bulunamadı', ColorConstants.redColor);
      return;
    }

    try {
      isLoading.value = true;
      hasResult.value = false;

      // Kıyafet resmini indir
      final garmentPath = await _downloadGarmentImage(garmentImageUrl.value);

      if (garmentPath == null) {
        throw Exception('Kıyafet resmi indirilemedi');
      }

      // Virtual Try-On işlemini başlat
      final result = await _tryOnService.tryOnClothing(
        garmentImagePath: garmentPath,
        personImagePath: selectedPersonImage.value,
      );

      if (result != null && result.isNotEmpty) {
        resultImageUrl.value = result;
        hasResult.value = true;
        showSnackBar('Başarılı', 'Sanal giyim denemesi tamamlandı!', ColorConstants.greenColor);
      } else {
        throw Exception('Sonuç alınamadı');
      }
    } catch (e) {
      showSnackBar('Hata', 'Giyim denemesi başarısız: $e', ColorConstants.redColor);
      debugPrint('Try-On Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kıyafet resmini indir
  Future<String?> _downloadGarmentImage(String imageUrl) async {
    try {
      final dio = Dio();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/garment_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await dio.download(imageUrl, filePath);
      return filePath;
    } catch (e) {
      debugPrint('Download Garment Error: $e');
      return null;
    }
  }

  /// Kıyafet URL'sini ayarla
  void setGarmentImage(String imageUrl) {
    garmentImageUrl.value = imageUrl;
  }

  /// Reset işlemi
  void reset() {
    selectedPersonImage.value = '';
    resultImageUrl.value = '';
    hasResult.value = false;
    isLoading.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
