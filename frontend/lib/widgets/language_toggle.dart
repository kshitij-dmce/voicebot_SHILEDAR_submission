import 'package:flutter/material.dart';
import '../data/user_config.dart';

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key});

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  String _currentLang = UserConfig.getLanguage();

  final Map<String, String> _langNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
  };

  void _changeLang(String langCode) {
    setState(() {
      _currentLang = langCode;
      UserConfig.setLanguage(langCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _currentLang,
      icon: const Icon(Icons.language),
      items: _langNames.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) _changeLang(value);
      },
    );
  }
}
