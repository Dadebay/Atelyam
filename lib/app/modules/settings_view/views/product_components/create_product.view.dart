import 'package:atelyam/app/modules/settings_view/controllers/product_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class CreateProductView extends StatelessWidget {
  CreateProductView({super.key});
  final ProductController controller = Get.put(ProductController());

  List<FocusNode> focusNodes = List.generate(3, (_) => FocusNode());
  List<TextEditingController> textEditingControllers = List.generate(3, (_) => TextEditingController());

  final Map<String, TextEditingController> descLangControllers = {
    'en': TextEditingController(),
    'ru': TextEditingController(),
    'ch': TextEditingController(),
    'uz': TextEditingController(),
    'tr': TextEditingController(),
  };

  final Map<String, TextEditingController> priceLangControllers = {
    'en': TextEditingController(),
    'ru': TextEditingController(),
    'ch': TextEditingController(),
    'uz': TextEditingController(),
    'tr': TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: WidgetsMine().appBar(
        appBarName: 'create_product'.tr,
        actions: [],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.whiteMainColor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'select_types_of_business'.tr,
                              style: TextStyle(
                                fontSize: AppFontSizes.getFontSize(5),
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kPrimaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.categories.length,
                              itemBuilder: (context, index) {
                                final category = controller.categories[index];
                                return ListTile(
                                  title: Text(category.localizedName),
                                  trailing: controller.selectedCategory.value?.id == category.id
                                      ? Icon(
                                          Icons.check,
                                          color: ColorConstants.kPrimaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    controller.selectedCategory.value = category;
                                    Get.back();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: controller.selectedCategory.value?.localizedName ?? '',
                    ),
                    decoration: InputDecoration(
                      labelText: 'select_types_of_business'.tr,
                      labelStyle: TextStyle(
                        fontSize: AppFontSizes.getFontSize(4),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(
                          color: ColorConstants.kPrimaryColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: Icon(
                        IconlyLight.arrow_down_circle,
                        color: Colors.grey.shade300,
                        size: 30,
                      ),
                    ),
                    validator: (value) => controller.selectedCategory.value == null ? 'fill_all_fields'.tr : null,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.whiteMainColor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'select_categories'.tr,
                              style: TextStyle(
                                fontSize: AppFontSizes.getFontSize(5),
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kPrimaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.hashtags.length,
                              itemBuilder: (context, index) {
                                final hashtag = controller.hashtags[index];
                                return ListTile(
                                  title: Text(hashtag.localizedName),
                                  trailing: controller.selectedHashtag.value?.id == hashtag.id
                                      ? Icon(
                                          Icons.check,
                                          color: ColorConstants.kPrimaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    controller.selectedHashtag.value = hashtag;
                                    Get.back();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: controller.selectedHashtag.value?.name ?? '',
                    ),
                    decoration: InputDecoration(
                      labelText: 'select_categories'.tr,
                      labelStyle: TextStyle(
                        fontSize: AppFontSizes.getFontSize(4),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadii.borderRadius20,
                        borderSide: BorderSide(
                          color: ColorConstants.kPrimaryColor,
                          width: 2,
                        ),
                      ),
                      suffixIcon: Icon(
                        IconlyLight.arrow_down_circle,
                        color: Colors.grey.shade300,
                        size: 30,
                      ),
                    ),
                    validator: (value) => controller.selectedHashtag.value == null ? 'fill_all_fields'.tr : null,
                  ),
                ),
              ),
            ),
          ),
          CustomTextField(
            labelName: 'product_name'.tr,
            borderRadius: true,
            customColor: Colors.grey.shade300,
            controller: textEditingControllers[0],
            prefixIcon: IconlyBroken.edit,
            showLabel: true,
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Obx(
              () => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadii.borderRadius20,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Icon(
                        IconlyBroken.wallet,
                        color: Colors.grey.shade400,
                        size: AppFontSizes.getFontSize(7),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppFontSizes.getFontSize(4.5),
                          fontWeight: FontWeight.w600,
                        ),
                        controller: textEditingControllers[1],
                        focusNode: focusNodes[1],
                        keyboardType: TextInputType.number,
                        onEditingComplete: () => focusNodes[2].requestFocus(),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'price'.tr,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: AppFontSizes.getFontSize(4.5),
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          Container(
                            decoration: BoxDecoration(
                              color: ColorConstants.whiteMainColor,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'select_currency'.tr,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.getFontSize(5),
                                      fontWeight: FontWeight.bold,
                                      color: ColorConstants.kPrimaryColor,
                                    ),
                                  ),
                                ),
                                ...['TMT', 'UZS', 'USD'].map((currency) {
                                  final isSelected = controller.selectedCurrency.value == currency;
                                  return ListTile(
                                    onTap: () {
                                      controller.selectedCurrency.value = currency;
                                      Get.back();
                                    },
                                    title: Text(
                                      currency,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? ColorConstants.kPrimaryColor : Colors.black,
                                      ),
                                    ),
                                    trailing: isSelected ? Icon(Icons.check_circle, color: ColorConstants.kPrimaryColor) : null,
                                  );
                                }),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedCurrency.value,
                              style: TextStyle(
                                color: ColorConstants.kPrimaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, color: ColorConstants.kPrimaryColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomTextField(
            labelName: 'description'.tr,
            borderRadius: true,
            maxLine: 6,
            showLabel: true,
            customColor: Colors.grey.shade300,
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[0],
            controller: textEditingControllers[2],
          ),
          _buildTranslationsSection(context),
          GestureDetector(
            onTap: controller.pickImage,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 250,
                width: 200,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadii.borderRadius20,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Obx(
                  () => controller.selectedImage.value == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyLight.image,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'main_image_upload'.tr,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadii.borderRadius20,
                          child: Image.file(
                            controller.selectedImage.value!,
                            width: Get.size.width,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'upload_images'.tr + ' (Max 4)',
                  style: TextStyle(
                    color: ColorConstants.kPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Obx(
                  () => GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: controller.selectedImages.length < 4 ? controller.selectedImages.length + 1 : controller.selectedImages.length,
                    itemBuilder: (context, index) {
                      if (index < controller.selectedImages.length) {
                        return WidgetsMine().buildImageItem(
                          image: controller.selectedImages[index]!,
                          onTap: () {
                            controller.selectedImages.removeAt(index);
                          },
                        );
                      } else {
                        return controller.selectedImages.length < controller.maxImageCount
                            ? WidgetsMine().buildUploadButton(
                                onTap: () {
                                  controller.pickImages();
                                },
                              )
                            : SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: AgreeButton(
              onTap: () async {
                await controller.addProductToBackend(
                  nameController: textEditingControllers[0].text,
                  descriptionController: textEditingControllers[2].text,
                  priceController: textEditingControllers[1].text,
                  descriptionEn: descLangControllers['en']!.text,
                  descriptionRu: descLangControllers['ru']!.text,
                  descriptionCh: descLangControllers['ch']!.text,
                  descriptionUz: descLangControllers['uz']!.text,
                  descriptionTr: descLangControllers['tr']!.text,
                  priceEn: priceLangControllers['en']!.text,
                  priceRu: priceLangControllers['ru']!.text,
                  priceCh: priceLangControllers['ch']!.text,
                  priceUz: priceLangControllers['uz']!.text,
                  priceTr: priceLangControllers['tr']!.text,
                );
              },
              text: 'upload_product'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationsSection(BuildContext context) {
    final langs = [
      {'code': 'en', 'label': '🇬🇧 English'},
      {'code': 'ru', 'label': '🇷🇺 Русский'},
      {'code': 'ch', 'label': '🇨🇳 中文'},
      {'code': 'uz', 'label': '🇺🇿 Uzbek'},
      {'code': 'tr', 'label': '🇹🇷 Türkçe'},
    ];
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.translate, color: ColorConstants.kPrimaryColor),
        title: Text(
          'other_languages'.tr,
          style: TextStyle(
            color: ColorConstants.kPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.getFontSize(4.5),
          ),
        ),
        children: langs.map((lang) => _buildLangFields(lang['code']!, lang['label']!)).toList(),
      ),
    );
  }

  Widget _buildLangFields(String code, String label) {
    final borderDecoration = OutlineInputBorder(
      borderRadius: BorderRadii.borderRadius15,
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    );
    final focusBorderDecoration = OutlineInputBorder(
      borderRadius: BorderRadii.borderRadius15,
      borderSide: BorderSide(color: ColorConstants.kPrimaryColor, width: 1.5),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.getFontSize(4),
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: descLangControllers[code],
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'description'.tr,
              border: borderDecoration,
              enabledBorder: borderDecoration,
              focusedBorder: focusBorderDecoration,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: priceLangControllers[code],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'price'.tr,
              border: borderDecoration,
              enabledBorder: borderDecoration,
              focusedBorder: focusBorderDecoration,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
