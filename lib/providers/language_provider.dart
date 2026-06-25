import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.tamil);

  void toggleLanguage() {
    state = state == AppLanguage.tamil
        ? AppLanguage.english
        : AppLanguage.tamil;
    AppStrings.currentLanguage = state;
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
    AppStrings.currentLanguage = lang;
  }
}
