// ignore_for_file: must_be_immutable
import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/modules/settings_view/controllers/product_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class CreateBusinessAccountView extends StatelessWidget {
  final ProductController controller = Get.put<ProductController>(ProductController());
  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.kSecondaryColor,
      title: Text(
        'new_business_account'.tr,
        style: TextStyle(
          color: ColorConstants.whiteMainColor,
          fontSize: AppFontSizes.fontSize16 + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: BackButtonMine(
        miniButton: true,
      ),
    );
  }

  List<FocusNode> focusNodes = List.generate(8, (_) => FocusNode());
  List<TextEditingController> textEditingControllers = List.generate(8, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: _appBar(context),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
            child: Obx(
              () => DropdownButtonFormField<BusinessCategoryModel>(
                decoration: InputDecoration(
                  labelText: 'select_types_of_business'.tr,
                  labelStyle: TextStyle(
                    fontSize: AppFontSizes.getFontSize(4),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadii.borderRadius20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadii.borderRadius20,
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadii.borderRadius20,
                    borderSide: BorderSide(
                      color: ColorConstants.kSecondaryColor,
                      width: 2,
                    ),
                  ),
                ),
                value: controller.selectedCategory.value,
                items: controller.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: AppFontSizes.getFontSize(4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => controller.selectedCategory.value = value,
                validator: (value) => value == null ? 'fill_all_fields'.tr : null,
              ),
            ),
          ),
          CustomTextField(
            labelName: 'business_name'.tr,
            controller: textEditingControllers[0],
            borderRadius: true,
            showLabel: true,
            customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PhoneNumberTextField(
              controller: textEditingControllers[1],
              focusNode: focusNodes[1],
              requestfocusNode: focusNodes[2],
            ),
          ),
          CustomTextField(
            labelName: 'address'.tr,
            controller: textEditingControllers[2],
            borderRadius: true,
            showLabel: true,
            maxLine: 5,
            customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomTextField(
              labelName: 'description'.tr,
              controller: textEditingControllers[3],
              borderRadius: true,
              showLabel: true,
              maxLine: 5,
              customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
              focusNode: focusNodes[3],
              requestfocusNode: focusNodes[4],
            ),
          ),
          CustomTextField(
            labelName: 'tiktok',
            controller: textEditingControllers[4],
            borderRadius: true,
            showLabel: true,
            customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomTextField(
              labelName: 'instagram',
              controller: textEditingControllers[5],
              borderRadius: true,
              showLabel: true,
              customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
              focusNode: focusNodes[5],
              requestfocusNode: focusNodes[6],
            ),
          ),
          CustomTextField(
            labelName: 'youtube',
            controller: textEditingControllers[6],
            borderRadius: true,
            showLabel: true,
            customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomTextField(
              labelName: 'website',
              controller: textEditingControllers[7],
              borderRadius: true,
              showLabel: true,
              customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
              focusNode: focusNodes[7],
              requestfocusNode: focusNodes[0],
            ),
          ),
          GestureDetector(
            onTap: controller.pickImage,
            child: Center(
              child: Container(
                height: 150,
                width: 150,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadii.borderRadius25,
                  border: Border.all(
                    color: ColorConstants.kSecondaryColor,
                    width: 2,
                  ),
                ),
                child: Obx(
                  () => controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadii.borderRadius25,
                          child: Image.file(
                            controller.selectedImage.value!,
                            width: Get.size.width,
                            height: Get.size.height,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(IconlyLight.image, size: 40),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'logo_upload'.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: AgreeButton(
                onTap: () {
                  if (textEditingControllers[0].text.isNotEmpty &&
                      textEditingControllers[1].text.isNotEmpty &&
                      textEditingControllers[2].text.isNotEmpty &&
                      textEditingControllers[3].text.isNotEmpty) {
                    controller.submitBusinessAccount(
                      GetMyStatusModel(
                        businessName: textEditingControllers[0].text,
                        businessPhone: textEditingControllers[1].text,
                        address: textEditingControllers[2].text,
                        description: textEditingControllers[3].text,
                        tiktok: textEditingControllers[4].text,
                        instagram: textEditingControllers[5].text,
                        youtube: textEditingControllers[6].text,
                        website: textEditingControllers[7].text,
                      ),
                    );
                  } else {
                    showSnackBar(
                      'error',
                      'fill_all_fields',
                      ColorConstants.redColor,
                    );
                  }
                },
                text: 'add_account'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
