import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/helper/language_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: BlocBuilder<LanguageCubit, String>(
          builder: (context, selectedLanguage) {
            return ListView(
              padding: EdgeInsets.all(10),
              children: [
                const SizedBox(height: 12),
                _languageTile(
                  context: context,
                  title: "English",
                  subtitle: "Use English language",
                  code: "en-IN",
                  isSelected: selectedLanguage == "en-IN",
                ),
                _languageTile(
                  context: context,
                  title: "हिंदी",
                  subtitle: "Hindi भाषा का उपयोग करें",
                  code: "hi-IN",
                  isSelected: selectedLanguage == "hi-IN",
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _languageTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () async {
        final isAvailable = await LanguageHelper.isLanguageAvailable(code);

        if (!isAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Language not available on this device")),
          );
          return;
        } else {
          context.read<LanguageCubit>().setLanguage(code);
        }
      },
    );
  }
}

class LanguageHelper {
  static final FlutterTts _tts = FlutterTts();

  static Future<bool> isLanguageAvailable(String code) async {
    final langs = await _tts.getLanguages;
    final inputPrefix = code.split("-").first.toLowerCase();
    for (final l in langs) {
      final langPrefix = l.split("-").first.toLowerCase();
      if (langPrefix.startsWith(inputPrefix)) {
        return true;
      }
    }

    return false;
  }
}
