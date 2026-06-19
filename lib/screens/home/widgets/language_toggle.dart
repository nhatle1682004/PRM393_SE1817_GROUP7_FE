import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);

    return InkWell(
      onTap: () => controller.toggle(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xfff8fafc),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffe2e8f0)),
        ),
        child: Row(
          children: [
            Text(
              controller.isVietnamese ? '🇻🇳' : '🇬🇧',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              controller.isVietnamese ? 'VI' : 'EN',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xff475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}