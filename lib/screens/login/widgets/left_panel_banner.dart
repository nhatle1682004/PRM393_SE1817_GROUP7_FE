import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';

class LeftPanelBanner extends StatelessWidget {
  const LeftPanelBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 550),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconBox(Icons.eco_outlined, const Color(0xff22c55e)),
                  const SizedBox(width: 16),
                  _buildIconBox(Icons.published_with_changes, const Color(0xff14b8a6)),
                  const SizedBox(width: 16),
                  _buildIconBox(Icons.forest_outlined, const Color(0xff15803d)),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                locale.tr('banner_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),
              ),
              const SizedBox(height: 20),
              Text(
                locale.tr('banner_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('50K+', locale.tr('stat_users')),
                  _buildStatItem('120T', locale.tr('stat_recycled')),
                  _buildStatItem('98%', locale.tr('stat_satisfaction')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xff10b981))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
