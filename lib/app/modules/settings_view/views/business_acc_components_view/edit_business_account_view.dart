import 'package:atelyam/app/modules/settings_view/controllers/product_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class EditBusinessAccountView extends StatefulWidget {
  final GetMyStatusModel businessUser;

  EditBusinessAccountView({required this.businessUser, super.key});

  @override
  State<EditBusinessAccountView> createState() => _EditBusinessAccountViewState();
}

class _EditBusinessAccountViewState extends State<EditBusinessAccountView> {
  final _formKey = GlobalKey<FormState>();
  final ProductController controller = Get.put(ProductController());
  @override
  void initState() {
    super.initState();
    textEditingControllers[0].text = widget.businessUser.businessName ?? '';
    textEditingControllers[1].text = widget.businessUser.businessPhone ?? '';
    textEditingControllers[2].text = widget.businessUser.address ?? '';
    textEditingControllers[3].text = widget.businessUser.description ?? '';
    textEditingControllers[4].text = widget.businessUser.instagram ?? '';
    textEditingControllers[5].text = widget.businessUser.tiktok ?? '';
    textEditingControllers[6].text = widget.businessUser.youtube ?? '';
    textEditingControllers[7].text = widget.businessUser.website ?? '';
  }

  final AuthController authController = Get.find();

  List<FocusNode> focusNodes = List.generate(8, (_) => FocusNode());
  List<TextEditingController> textEditingControllers = List.generate(8, (_) => TextEditingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Alanları
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
                      border: Border.all(color: ColorConstants.kSecondaryColor, width: 2),
                    ),
                    child: Obx(
                      () => controller.selectedImage.value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: Image.file(controller.selectedImage.value!, height: Get.size.height, width: Get.size.width, fit: BoxFit.cover),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: widget.businessUser.backPhoto == null
                                  ? WidgetsMine().buildUploadButton(
                                      onTap: () {
                                        controller.pickImage();
                                      },
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: authController.ipAddress.value + widget.businessUser.backPhoto!,
                                      fit: BoxFit.cover,
                                      fadeInCurve: Curves.ease,
                                      height: Get.size.height,
                                      width: Get.size.width,
                                      placeholder: (context, url) => EmptyStates().loadingData(),
                                      errorWidget: (context, url, error) => EmptyStates().noMiniCategoryImage(),
                                    ),
                            ),
                    ),
                  ),
                ),
              ),
              Center(
                child: AgreeButton(
                  onTap: () {
                    final String photo = controller.selectedImage.value == null ? widget.businessUser.backPhoto! : controller.selectedImage.value!.path;
                    controller.updateBusinessAccount(
                      GetMyStatusModel(
                        id: widget.businessUser.id,
                        businessName: textEditingControllers[0].text,
                        businessPhone: textEditingControllers[1].text,
                        address: textEditingControllers[2].text,
                        description: textEditingControllers[3].text,
                        tiktok: textEditingControllers[4].text,
                        instagram: textEditingControllers[5].text,
                        youtube: textEditingControllers[6].text,
                        website: textEditingControllers[7].text,
                      ),
                      photo,
                    );
                  },
                  text: 'update'.tr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.kSecondaryColor,
      title: Text(
        'update_business_account'.tr, // Başlık metni
        style: TextStyle(
          color: ColorConstants.whiteMainColor,
          fontSize: AppFontSizes.fontSize16 + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(IconlyLight.delete, color: Colors.white),
          onPressed: () {
            Dialogs().deleteBusinessAccount();
          },
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: ColorConstants.kSecondaryColor),
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            IconlyLight.arrow_left_circle,
            color: ColorConstants.warmWhiteColor,
            size: AppFontSizes.getFontSize(8),
          ),
        ),
      ),
    );
  }
}
