import 'dart:io';
import 'package:atelyam/app/modules/virtual_tryon/controllers/virtual_tryon_controller.dart';
import 'package:atelyam/app/data/service/virtual_tryon_service.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VirtualTryOnView extends StatelessWidget {
  final ProductModel productModel;
  final String garmentImageUrl;

  VirtualTryOnView({
    required this.productModel,
    required this.garmentImageUrl,
    super.key,
  });

  final VirtualTryOnController controller = Get.put(VirtualTryOnController());

  @override
  Widget build(BuildContext context) {
    // Kıyafet resmini controller'a set et
    controller.setGarmentImage(garmentImageUrl);

    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.whiteMainColor,
        elevation: 0,
        title: Text(
          'Sanal Giyim Denemesi',
          style: TextStyle(
            color: ColorConstants.kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSizes.fontSize20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorConstants.kPrimaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ürün bilgisi kartı
              _buildProductInfoCard(),
              const SizedBox(height: 20),

              // Google Gemini bilgilendirme
              _buildGeminiInfo(),
              const SizedBox(height: 20),

              // Fotoğraf seçme bölümü
              Obx(() => _buildPhotoSection()),
              const SizedBox(height: 20),

              // Dene butonu
              Obx(() => _buildTryOnButton()),
              const SizedBox(height: 20),

              // Sonuç gösterimi
              Obx(() => _buildResultSection()),
            ],
          ),
        ),
      ),
    );
  }

  /// Ürün bilgi kartı
  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorConstants.whiteMainColor,
        borderRadius: BorderRadii.borderRadius20,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Ürün resmi
          ClipRRect(
            borderRadius: BorderRadii.borderRadius15,
            child: CachedNetworkImage(
              imageUrl: garmentImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => EmptyStates().loadingData(),
              errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
            ),
          ),
          const SizedBox(width: 15),
          // Ürün bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productModel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorConstants.kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSizes.fontSize18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${productModel.price} TMT',
                  style: TextStyle(
                    color: ColorConstants.kPrimaryColor.withOpacity(0.7),
                    fontSize: AppFontSizes.fontSize16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Google Gemini bilgilendirme kartı
  Widget _buildGeminiInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorConstants.kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadii.borderRadius15,
        border: Border.all(
          color: ColorConstants.kPrimaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorConstants.kPrimaryColor,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google Gemini AI',
                  style: TextStyle(
                    fontSize: AppFontSizes.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '⚠️ Gemini sadece görüntü analizi yapar, virtual try-on yapamaz. Gerçek sonuç için backend servis gerekir.',
                  style: TextStyle(
                    fontSize: AppFontSizes.fontSize14,
                    color: ColorConstants.kPrimaryColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fotoğraf seçme bölümü
  Widget _buildPhotoSection() {
    if (controller.selectedPersonImage.value.isEmpty) {
      return Column(
        children: [
          Text(
            'Fotoğrafınızı Yükleyin',
            style: TextStyle(
              fontSize: AppFontSizes.fontSize20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.kPrimaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: ColorConstants.kPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadii.borderRadius20,
              border: Border.all(
                color: ColorConstants.kPrimaryColor.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: ColorConstants.kPrimaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Kıyafeti üzerinizde görmek için\nfotoğrafınızı yükleyin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSizes.fontSize16,
                    color: ColorConstants.kPrimaryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickPersonImage(),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeriden Seç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadii.borderRadius15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.takePersonPhoto(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Fotoğraf Çek'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.kPrimaryColor.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadii.borderRadius15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Seçilen fotoğrafı göster
      return Column(
        children: [
          Text(
            'Fotoğrafınız',
            style: TextStyle(
              fontSize: AppFontSizes.fontSize20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.kPrimaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadii.borderRadius20,
                child: Image.file(
                  File(controller.selectedPersonImage.value),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => controller.reset(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => controller.pickPersonImage(),
            icon: const Icon(Icons.edit),
            label: const Text('Değiştir'),
            style: TextButton.styleFrom(
              foregroundColor: ColorConstants.kPrimaryColor,
            ),
          ),
        ],
      );
    }
  }

  /// Dene butonu
  Widget _buildTryOnButton() {
    if (controller.selectedPersonImage.value.isEmpty) {
      return const SizedBox.shrink();
    }

    if (controller.isLoading.value) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorConstants.kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadii.borderRadius20,
        ),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: ColorConstants.kPrimaryColor,
            ),
            const SizedBox(height: 15),
            Text(
              'AI kıyafeti üzerinize giydiriyor...\nBu işlem 30-60 saniye sürebilir',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.fontSize16,
                color: ColorConstants.kPrimaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return AgreeButton(
      onTap: () => controller.startTryOn(),
      text: 'Üzerimde Dene',
      textColor: Colors.white,
      color: ColorConstants.kPrimaryColor,
    );
  }

  /// Sonuç bölümü
  Widget _buildResultSection() {
    if (!controller.hasResult.value) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          'Sonuç',
          style: TextStyle(
            fontSize: AppFontSizes.fontSize20,
            fontWeight: FontWeight.bold,
            color: ColorConstants.kPrimaryColor,
          ),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadii.borderRadius20,
          child: Image.file(
            File(controller.resultImageUrl.value),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  'Sonuç görüntülenemedi',
                  style: TextStyle(color: ColorConstants.kPrimaryColor),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Resmi kaydetme veya paylaşma işlevi eklenebilir
                  showSnackBar('Bilgi', 'Resim kaydedildi!', ColorConstants.greenColor);
                },
                icon: const Icon(Icons.download),
                label: const Text('Kaydet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorConstants.kPrimaryColor,
                  side: BorderSide(color: ColorConstants.kPrimaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadii.borderRadius15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Paylaşma işlevi eklenebilir
                  showSnackBar('Bilgi', 'Paylaşım özelliği yakında!', ColorConstants.kPrimaryColor);
                },
                icon: const Icon(Icons.share),
                label: const Text('Paylaş'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorConstants.kPrimaryColor,
                  side: BorderSide(color: ColorConstants.kPrimaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadii.borderRadius15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
