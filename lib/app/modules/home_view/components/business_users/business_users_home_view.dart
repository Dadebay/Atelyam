import 'package:atelyam/app/data/models/business_user_model.dart';
import 'package:atelyam/app/data/service/business_user_service.dart';
import 'package:atelyam/app/modules/home_view/components/business_users/brend_card.dart';
import 'package:atelyam/app/product/custom_widgets/listview_top_name_and_icon.dart';
import 'package:atelyam/app/product/empty_states/empty_states.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';

class BusinessUsersHomeView extends StatefulWidget {
  const BusinessUsersHomeView({super.key});

  @override
  State<BusinessUsersHomeView> createState() => _BusinessUsersHomeViewState();
}

class _BusinessUsersHomeViewState extends State<BusinessUsersHomeView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.7);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        double page = _pageController.initialPage.toDouble();

                        if (_pageController.hasClients &&
                            _pageController.position.haveDimensions) {
                          page = _pageController.page!;
                          value = (1 - ((page - index).abs() * 0.3))
                              .clamp(0.0, 1.0);
                        } else {
                          value =
                              index == _pageController.initialPage ? 1.0 : 0.7;
                        }

                        final double scale = Curves.easeOut.transform(value);

                        return Center(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..scale(scale),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorConstants.kSecondaryColor
                                        .withOpacity(0.08),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: BrendCard(
                                businessUserModel: users[index],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
