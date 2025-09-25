import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/settings_view/controllers/product_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class CreateProductView extends StatelessWidget {
  CreateProductView({super.key});
  final ProductController controller = Get.put(ProductController());

  List<FocusNode> focusNodes = List.generate(3, (_) => FocusNode());
  List<TextEditingController> textEditingControllers = List.generate(3, (_) => TextEditingController());

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
              () => DropdownButtonFormField<BusinessCategoryModel>(
                decoration: InputDecoration(
                  labelText: 'select_types_of_business'.tr,
                  labelStyle: TextStyle(fontSize: AppFontSizes.getFontSize(4), fontWeight: FontWeight.w600, color: Colors.grey.shade400),
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
                    borderSide: BorderSide(color: ColorConstants.kPrimaryColor, width: 2),
                  ),
                ),
                value: controller.selectedCategory.value,
                items: controller.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(category.name),
                    ),
                  );
                }).toList(),
                icon: Icon(IconlyLight.arrow_down_circle, color: Colors.grey.shade300, size: 30), // Ok ikonunun boyutunu artır
                iconSize: 30, // Ok ikonunun boyutunu artır
                isExpanded: true, // Dropdown'u genişlet
                itemHeight: 60, // D
                onChanged: (value) => controller.selectedCategory.value = value,
                validator: (value) => value == null ? 'fill_all_fields'.tr : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Obx(
              () => DropdownButtonFormField<HashtagModel>(
                decoration: InputDecoration(
                  labelText: 'select_categories'.tr,
                  labelStyle: TextStyle(fontSize: AppFontSizes.getFontSize(4), fontWeight: FontWeight.w600, color: Colors.grey.shade400),
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
                    borderSide: BorderSide(color: ColorConstants.kPrimaryColor, width: 2),
                  ),
                ),
                value: controller.selectedHashtag.value,
                items: controller.hashtags.map((hashtag) {
                  return DropdownMenuItem(
                    value: hashtag,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(hashtag.name),
                    ),
                  );
                }).toList(),
                icon: Icon(IconlyLight.arrow_down_circle, color: Colors.grey.shade300, size: 30), // Ok ikonunun boyutunu artır
                iconSize: 30, // Ok ikonunun boyutunu artır
                isExpanded: true, // Dropdown'u genişlet
                itemHeight: 60, // D
                onChanged: (value) => controller.selectedHashtag.value = value,
                validator: (value) => value == null ? 'fill_all_fields'.tr : null,
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
          CustomTextField(
            labelName: 'price'.tr,
            controller: textEditingControllers[1],
            borderRadius: true,
            showLabel: true,
            prefixIcon: IconlyBroken.wallet,
            customColor: Colors.grey.shade300,
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
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
                            Icon(IconlyLight.image, color: Colors.grey.shade400, size: 40),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'main_image_upload'.tr,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
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
                );
              },
              text: 'upload_product'.tr,
            ),
          ),
        ],
      ),
    );
  }
}
