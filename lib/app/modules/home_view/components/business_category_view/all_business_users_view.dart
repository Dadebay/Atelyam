// lib/app/modules/all_brend_view/views/all_brend_view.dart

import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/service/business_user_service.dart';
import 'package:atelyam/app/modules/home_view/components/business_category_view/business_user_card_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllBusinessUsersView extends StatelessWidget {
  final int categoryId;

  AllBusinessUsersView({required this.categoryId, super.key});

  @override
  Widget build(BuildContext context) {
    print(categoryId);

    return Scaffold(
      body: Stack(
        children: [
          BackgroundPattern(),
          TransparentAppBar(title: 'commecial_users'.tr, actions: [], removeLeading: false, color: ColorConstants.whiteMainColor),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40),
            child: FutureBuilder<List<BusinessUserModel>?>(
              future: BusinessUserService().getBusinessAccountsByCategory(categoryID: categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return EmptyStates().loadingData();
                } else if (snapshot.hasError) {
                  return EmptyStates().errorData(snapshot.hasError.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return EmptyStates().noDataAvailablePage(textColor: ColorConstants.whiteMainColor);
                } else {
                  final List<BusinessUserModel> categories = snapshot.data!;
                  return GridView.builder(
                    itemCount: categories.length,
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
                    itemBuilder: (BuildContext context, index) {
                      return BusinessUsersCardView(
                          category: categories[index],
                          categoryID: categoryId,
                        );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
