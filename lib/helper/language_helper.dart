import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<String> {
  static const String _prefsKey = 'selected_language';
  LanguageCubit({String defaultLanguage = 'en-IN'}) : super(defaultLanguage) {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && saved.isNotEmpty && saved != state) {
      emit(saved);
    }
  }

  /// Sets the current language and persists it to SharedPreferences.
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == state) return;
    emit(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }

  /// Returns the current language code.
  String get currentLanguage => state;

  /// Clears saved language and resets to [defaultLanguage] or 'en'.
  Future<void> clearLanguage({String defaultLanguage = 'en-IN'}) async {
    emit(defaultLanguage);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
