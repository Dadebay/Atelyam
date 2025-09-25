import 'dart:io';

import 'package:atelyam/app/data/models/business_category_model.dart';
import 'package:atelyam/app/data/service/image_service.dart';
import 'package:atelyam/app/modules/settings_view/controllers/product_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';

class UpdateProductView extends StatefulWidget {
  final ProductModel product;

  const UpdateProductView({required this.product, super.key});

  @override
  State<UpdateProductView> createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  final ProductController controller = Get.put(ProductController());

  final List<FocusNode> focusNodes = List.generate(3, (_) => FocusNode());

  final List<TextEditingController> textControllers = List.generate(3, (_) => TextEditingController());
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  final ImageService _imageService = ImageService();

  Future<void> _initializeData() async {
    textControllers[0].text = widget.product.name;
    textControllers[1].text = widget.product.price.toString();
    textControllers[2].text = widget.product.description;
    await controller.loadCategories().then((a) {
      controller.selectedCategory.value = controller.categories.firstWhereOrNull((e) => e.id == widget.product.category);
    });
    await controller.loadHashtags().then((a) {
      controller.selectedHashtag.value = controller.hashtags.firstWhereOrNull((e) => e.id == widget.product.hashtag);
    });
    await _imageService.fetchImageByProductID(widget.product.id).then((image) {
      print(image!.images);
      image.images.forEach((element) {
        controller.deleteImageNames.add(element);

        if (element == null) {
        } else {
          controller.selectedImagesEditProduct.add(element);
        }
      });
    });
    print(controller.deleteImageNames);
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Center(
        child: Container(
          height: 250,
          width: 200,
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadii.borderRadius20,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Obx(() {
            if (controller.selectedImage.value != null) {
              return ClipRRect(
                borderRadius: BorderRadii.borderRadius20,
                child: Image.file(
                  controller.selectedImage.value!,
                  fit: BoxFit.cover,
                ),
              );
            }
            if (widget.product.img.toString() != 'null') {
              return ClipRRect(
                borderRadius: BorderRadii.borderRadius20,
                child: CachedNetworkImage(
                  imageUrl: '${controller.authController.ipAddress.value}${widget.product.img}',
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyLight.image, color: ColorConstants.kPrimaryColor, size: 40),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'update_image'.tr,
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: AppFontSizes.getFontSize(5),
        fontWeight: FontWeight.bold,
        color: ColorConstants.kPrimaryColor,
      ),
      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      border: OutlineInputBorder(borderRadius: BorderRadii.borderRadius15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadii.borderRadius20,
        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadii.borderRadius20,
        borderSide: BorderSide(color: ColorConstants.kPrimaryColor, width: 2),
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context) async {
    final selectedCategory = await showDialog<BusinessCategoryModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'select_types_of_business'.tr,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorConstants.kPrimaryColor,
              fontSize: AppFontSizes.getFontSize(5),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: controller.categories.map((category) {
                return ListTile(
                  title: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor,
                      fontSize: AppFontSizes.getFontSize(4.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, category); // Seçilen kategoriyi döndür
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCategory != null) {
      controller.selectedCategory.value = selectedCategory;
    }
  }

  Future<void> _showHashtagDialog(BuildContext context) async {
    final selectedHashtag = await showDialog<HashtagModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'select_categories'.tr,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorConstants.kPrimaryColor,
              fontSize: AppFontSizes.getFontSize(5),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: controller.hashtags.map((category) {
                return ListTile(
                  title: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor,
                      fontSize: AppFontSizes.getFontSize(4.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, category); // Seçilen kategoriyi döndür
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selectedHashtag != null) {
      controller.selectedHashtag.value = selectedHashtag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      appBar: WidgetsMine().appBar(
        appBarName: 'update_product'.tr,
        actions: [
          IconButton(
            onPressed: () {
              Dialogs().deleteProductDialog(productID: widget.product.id);
            },
            icon: const Icon(IconlyLight.delete, color: ColorConstants.whiteMainColor),
          ),
        ],
      ),
      body: Obx(() {
        return controller.categories.isEmpty
            ? EmptyStates().loadingData()
            : ListView(
                children: [
                  productStatus(),
                  Padding(
                    padding: EdgeInsets.only(top: 30, left: 15, right: 15),
                    child: TextField(
                      decoration: _dropdownDecoration('types_of_business'.tr),
                      controller: TextEditingController(text: controller.selectedCategory.value?.name ?? ''),
                      readOnly: true, // Kullanıcının metni değiştirmesini engeller
                      onTap: () {
                        _showCategoryDialog(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                    child: TextField(
                      decoration: _dropdownDecoration('categories'.tr),
                      controller: TextEditingController(text: controller.selectedHashtag.value?.name ?? ''),
                      readOnly: true, // Kullanıcının metni değiştirmesini engeller
                      onTap: () {
                        _showHashtagDialog(context);
                      },
                    ),
                  ),
                  CustomTextField(
                    labelName: 'product_name'.tr,
                    controller: textControllers[0],
                    prefixIcon: IconlyBroken.edit,
                    customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
                    borderRadius: true,
                    showLabel: true,
                    focusNode: focusNodes[0],
                    requestfocusNode: focusNodes[1],
                  ),
                  CustomTextField(
                    labelName: 'price'.tr,
                    customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
                    borderRadius: true,
                    controller: textControllers[1],
                    prefixIcon: IconlyBroken.wallet,
                    focusNode: focusNodes[1],
                    showLabel: true,
                    requestfocusNode: focusNodes[2],
                  ),
                  CustomTextField(
                    labelName: 'description'.tr,
                    controller: textControllers[2],
                    maxLine: 6,
                    showLabel: true,
                    customColor: ColorConstants.kPrimaryColor.withOpacity(.2),
                    borderRadius: true,
                    focusNode: focusNodes[2],
                    requestfocusNode: focusNodes[0],
                  ),
                  _buildImageSection(),
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
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: controller.selectedImagesEditProduct.isEmpty ? 4 : 4,
                          itemBuilder: (context, index) {
                            if (index < controller.selectedImagesEditProduct.length) {
                              final image = controller.selectedImagesEditProduct[index];
                              if (image != null) {
                                if (image.startsWith('/media/')) {
                                  return WidgetsMine().buildImageItemEditProduct(
                                    image: image,
                                    onTap: () {
                                      for (int a = 0; a < 4; a++) {
                                        if (controller.deleteImageNames[a] == controller.selectedImagesEditProduct[index]) {
                                          controller.deleteSelectedImage(widget.product.id, a + 1);
                                        }
                                      }
                                      controller.selectedImagesEditProduct.removeAt(index);
                                      controller.selectedImagesEditProduct.refresh();
                                    },
                                  );
                                } else if (image.startsWith('/data/') || image.startsWith('file://')) {
                                  return WidgetsMine().buildImageItem(
                                    image: File(image),
                                    onTap: () {
                                      controller.selectedImagesEditProduct.removeAt(index);
                                    },
                                  );
                                } else if (image is File) {
                                  return WidgetsMine().buildImageItem(
                                    image: File(image),
                                    onTap: () {
                                      controller.selectedImagesEditProduct.removeAt(index);
                                    },
                                  );
                                }
                              }
                            }
                            return WidgetsMine().buildUploadButton(
                              onTap: () {
                                controller.pickImages(isEditProduct: true);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: AgreeButton(
                      onTap: () {
                        controller
                            .updateProduct(
                          productId: widget.product.id,
                          nameController: textControllers[0].text,
                          descriptionController: textControllers[2].text,
                          priceController: textControllers[1].text,
                        )
                            .then((a) {
                          controller.uploadProductImages(widget.product.id);
                        });
                      },
                      text: 'update_product'.tr,
                    ),
                  ),
                ],
              );
      }),
    );
  }

  Padding productStatus() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 15),
      child: Row(
        children: [
          Text(
            'product_status'.tr + '  : ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFontSizes.getFontSize(4),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              widget.product.status.toString() == 'true' ? 'pending'.tr : 'active'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFontSizes.getFontSize(5),
                fontWeight: FontWeight.bold,
                color: ColorConstants.darkMainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
