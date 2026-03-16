import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ─── Currency enum & formatting (shared across all business pages) ─────────────
enum AppCurrency { usd, tmt, uzs }

extension AppCurrencyExt on AppCurrency {
  String get symbol {
    switch (this) {
      case AppCurrency.usd:
        return '\$';
      case AppCurrency.tmt:
        return 'TMT';
      case AppCurrency.uzs:
        return "so'm";
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.usd:
        return 'USD';
      case AppCurrency.tmt:
        return 'TMT';
      case AppCurrency.uzs:
        return 'UZS';
    }
  }

  String format(double usdAmount) {
    if (this == AppCurrency.uzs || this == AppCurrency.tmt) {
      final formatted = usdAmount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
      return '$formatted $symbol';
    }
    return '$symbol${usdAmount.toStringAsFixed(0)}';
  }
}

// ─── GetX controller ──────────────────────────────────────────────────────────
class BusinessCurrencyController extends GetxController {
  final currency = AppCurrency.usd.obs;

  @override
  void onInit() {
    super.onInit();
    final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
    if (langCode == 'tm') {
      currency.value = AppCurrency.tmt;
    } else if (langCode == 'uz') {
      currency.value = AppCurrency.uzs;
    } else {
      currency.value = AppCurrency.usd;
    }
  }

  void select(AppCurrency c) => currency.value = c;
}
