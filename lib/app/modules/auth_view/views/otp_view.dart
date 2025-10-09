import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:lottie/lottie.dart';

class OTPView extends StatelessWidget {
  final String phoneNumber;
  final String userName;

  OTPView({required this.phoneNumber, required this.userName, Key? key}) : super(key: key);

  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(child: BackgroundPattern()),
          TransparentAppBar(title: 'verify_phone', miniBackButton: true, removeLeading: false, color: Colors.white),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildOTPContent(context),
          ),
        ],
      ),
    );
  }


  Widget _buildOTPContent(BuildContext context) {
    return Container(
      height: Get.size.height / 1.2,
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: ColorConstants.whiteMainColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Lottie.asset(
            Assets.otp_loading,
            height: 200,
            width: 200,
          ),
          Text(
            'code_has_been_sent_to'.tr + ': +993$phoneNumber',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 2,
              color: Colors.grey,
            ),
          ),
          _buildOTPFields(context),
          AgreeButton(
            onTap: () {
              authController.verifyOTP(username: userName, phoneNumber: phoneNumber, otpControllers: _otpControllers);
            },
            text: 'verify',
          ),
        ],
      ),
    );
  }

  Widget _buildOTPFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 55,
          child: TextField(
            autofocus: index == 0, // İlk alana otomatik odaklan
            style: TextStyle(color: ColorConstants.darkMainColor, fontWeight: FontWeight.bold, fontSize: 20),
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadii.borderRadius15,
                borderSide: const BorderSide(color: ColorConstants.warmWhiteColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadii.borderRadius20,
                borderSide: BorderSide(color: ColorConstants.kPrimaryColor, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                // Bir sonraki alana odaklan
                FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                // Bir önceki alana odaklan
                FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
              }

              // Tüm alanlar doluysa OTP'yi doğrula
              if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
                print('iseldim');
                authController.verifyOTP(username: userName, phoneNumber: phoneNumber, otpControllers: _otpControllers);
              }
            },
          ),
        );
      }),
    );
  }
}
