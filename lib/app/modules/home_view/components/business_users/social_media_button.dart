import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaIcon extends StatelessWidget {
  final String icon;
  final int index;
  final String name;
  final String userName;
  final int maxline;

  const SocialMediaIcon({
    required this.icon,
    required this.index,
    required this.name,
    required this.userName,
    required this.maxline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String displayedUserName = userName;
    String urlToLaunch;

    if (userName.startsWith('@')) {
      // @ ile başlıyorsa, platform URL'i oluştur
      String platformUrl = '';
      switch (name) {
        case 'Instagram':
          platformUrl = 'https://www.instagram.com/${userName.substring(1)}';
          break;
        case 'TikTok':
          platformUrl = 'https://www.tiktok.com/@${userName.substring(1)}';
          break;
        case 'Youtube':
          platformUrl = 'https://youtube.com/${userName.substring(1)}';
          break;
        default:
          platformUrl = userName;
      }
      urlToLaunch = platformUrl;
      displayedUserName = userName; // @username olarak göster
    } else if (userName.startsWith('http://') || userName.startsWith('https://')) {
      // URL ise, username'i çıkar
      urlToLaunch = userName;

      // Instagram, TikTok, YouTube URL'lerinden username çıkar
      if (userName.contains('instagram.com/')) {
        final username = userName.split('instagram.com/').last.replaceAll('/', '');
        displayedUserName = '@$username';
      } else if (userName.contains('tiktok.com/@')) {
        final username = userName.split('tiktok.com/@').last.replaceAll('/', '');
        displayedUserName = '@$username';
      } else if (userName.contains('youtube.com/')) {
        final username = userName.split('youtube.com/').last.replaceAll('/', '');
        displayedUserName = '@$username';
      } else {
        // Diğer URL'ler için domain göster
        try {
          displayedUserName = Uri.parse(userName).host;
        } catch (e) {
          displayedUserName = userName;
        }
      }
    } else if (userName.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(userName)) {
      // Telefon numarası
      urlToLaunch = 'tel:$userName';
      displayedUserName = userName;
    } else {
      // Düz metin
      urlToLaunch = userName;
      displayedUserName = userName;
    }

    return GestureDetector(
      onTap: () async {
        print('🔵 Launching: $urlToLaunch');
        final Uri url = Uri.parse(urlToLaunch);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          print('🟢 Successfully launched: $urlToLaunch');
        } else {
          print('🔴 Cannot launch: $urlToLaunch');
          showSnackBar('url_error', 'url_error_message', ColorConstants.darkMainColor);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 50),
        child: Row(
          children: [
            Container(
              width: AppFontSizes.getFontSize(12),
              height: AppFontSizes.getFontSize(12),
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadii.borderRadius18,
                color: ColorConstants.kSecondaryColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadii.borderRadius18,
                child: Center(
                  child: Image.asset(
                    icon,
                    color: Colors.white,
                    width: AppFontSizes.getFontSize(
                      icon == Assets.tiktok
                          ? 10
                          : icon == Assets.address
                              ? 10
                              : 7,
                    ),
                    height: AppFontSizes.getFontSize(
                      icon == Assets.tiktok
                          ? 10
                          : icon == Assets.address
                              ? 10
                              : 7,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.getFontSize(3.5),
                      color: ColorConstants.darkMainColor.withOpacity(.6),
                    ),
                  ),
                  Text(
                    displayedUserName,
                    maxLines: maxline,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.getFontSize(4.5),
                      color: ColorConstants.kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Icon(
                IconlyLight.arrow_right_circle,
                color: ColorConstants.kPrimaryColor,
                size: AppFontSizes.getFontSize(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
