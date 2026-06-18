import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    return TextButton(
      onPressed: locale.toggle,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xfff1f5f9),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        locale.isVietnamese ? locale.tr('lang_vi') : locale.tr('lang_en'),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff334155)),
      ),
    );
  }
}
