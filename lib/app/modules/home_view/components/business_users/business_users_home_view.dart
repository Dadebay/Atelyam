import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/service/business_user_service.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/brend_card.dart';
import 'package:atelyam/app/product/custom_widgets/listview_top_name_and_icon.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BusinessUsersHomeView extends StatefulWidget {
  const BusinessUsersHomeView({super.key});

  @override
  State<BusinessUsersHomeView> createState() => _BusinessUsersHomeViewState();
}

class _BusinessUsersHomeViewState extends State<BusinessUsersHomeView> {
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BusinessUserModel>?>(
      future: BusinessUserService().fetchPopularBusinessAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final users = snapshot.data!;

          return Column(
            children: [
              ListviewTopNameAndIcon(
                text: 'most_popular_users',
                icon: false,
                onTap: () {},
              ),
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: users.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadii.borderRadius30,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 12),
                      ],
                    ),
                    child: BrendCard(businessUserModel: users[index]),
                  );
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.43,
                  viewportFraction: 0.7,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOut,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
