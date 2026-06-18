import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/widgets/language_toggle.dart';

class HeaderSection extends StatefulWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;

  const HeaderSection({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final StorageService _storageService = StorageService();
  String? _savedName;
  String _avatarLetters = '--';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? savedName = await _storageService.getUsername();
    if (!mounted) return;
    setState(() {
      _savedName = savedName;
      if (savedName != null && savedName.isNotEmpty) {
        _avatarLetters = savedName.substring(0, savedName.length >= 2 ? 2 : 1).toUpperCase();
      } else {
        _avatarLetters = 'G';
      }
      _loaded = true;
    });
  }

  String _displayName(LocaleController locale) {
    if (!_loaded) return locale.tr('loading');
    if (_savedName == null || _savedName!.isEmpty) return locale.tr('guest');
    return _savedName!;
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    final text = locale.text;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    final displayName = _displayName(locale);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xffe2e8f0), width: 1)),
        boxShadow: [BoxShadow(color: const Color(0xff0f172a).withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xffdcfce7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.eco, color: Color(0xff10b981), size: 24),
          ),
          const SizedBox(width: 10),
          Text(locale.tr('app_name'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xff0f172a), letterSpacing: -0.5)),
          const SizedBox(width: 32),
          if (!isMobile)
            Row(
              children: [
                _navButton(text['home']!, index: 0),
                _navButton(text['create_report']!, index: 1),
                _navButton(text['rewards']!, index: 2),
                _navButton(text['history']!, index: 3),
              ],
            )
          else
            IconButton(icon: const Icon(Icons.menu, color: Color(0xff475569)), onPressed: () {}),
          const Spacer(),
          const LanguageToggle(),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.notifications, color: Color(0xff64748b), size: 24), onPressed: () {}),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xfff0fdf4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffbbf7d0))),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xff10b981), size: 16),
                const SizedBox(width: 4),
                Text('0 ${locale.tr('points_unit')}', style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xfff8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffe2e8f0))),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xff10b981),
                  child: Text(_avatarLetters, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(displayName, style: const TextStyle(color: Color(0xff334155), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Color(0xff64748b), size: 22),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String label, {required int index}) {
    bool isActive = widget.currentTabIndex == index;
    return InkWell(
      onTap: () => widget.onTabChanged(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xfff0fdf4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xff10b981) : const Color(0xff64748b),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
