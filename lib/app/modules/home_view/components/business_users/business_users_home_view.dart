import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/service/business_user_service.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/brend_card.dart';
import 'package:atelyam/app/product/custom_widgets/listview_top_name_and_icon.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:flutter/material.dart';

class BusinessUsersHomeView extends StatelessWidget {
  const BusinessUsersHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<BusinessUserModel>?>(
      future: BusinessUserService().fetchPopularBusinessAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.hasError.toString());
        } else if (snapshot.hasData) {
          return Column(
            children: [
              ListviewTopNameAndIcon(
                text: 'most_popular_users',
                icon: false,
                onTap: () {},
              ),
              Container(
                height: screenHeight * 0.40,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemExtent: screenWidth * 0.80,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: BrendCard(
                        showAllBrends: false,
                        businessUserModel: snapshot.data![index],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
