import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/widgets/create_report_screen.dart';
import 'package:waste_collection_management_system/screens/home/widgets/header_section.dart';
import 'package:waste_collection_management_system/screens/home/widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    final text = locale.text;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xfff1f5f9),
      body: Column(
        children: [
          HeaderSection(
            currentTabIndex: _currentTabIndex,
            onTabChanged: (index) => setState(() => _currentTabIndex = index),
          ),
          Expanded(
            child: _currentTabIndex == 1
                ? const CreateReportScreen()
                : _buildDashboardHome(isMobile, text),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(bool isMobile, Map<String, String> text) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối Stats Cards
          isMobile
              ? Column(
            children: [
              StatsCard(
                title: text['total_points']!, value: '0',
                subtitle: text['points_subtitle']!,
                icon: Icons.eco, iconBgColor: const Color(0xfff0fdf4), iconColor: const Color(0xff10b981),
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: text['reports_submitted']!, value: '0',
                subtitle: text['reports_subtitle']!,
                icon: Icons.assignment, iconBgColor: const Color(0xfffef3c7), iconColor: Colors.amber,
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: text['reward_events']!, value: '0',
                subtitle: text['events_subtitle']!,
                icon: Icons.emoji_events, iconBgColor: const Color(0xfffee2e2), iconColor: Colors.redAccent,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: text['total_points']!, value: '0',
                  subtitle: text['points_subtitle']!,
                  icon: Icons.eco, iconBgColor: const Color(0xfff0fdf4), iconColor: const Color(0xff10b981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: text['reports_submitted']!, value: '0',
                  subtitle: text['reports_subtitle']!,
                  icon: Icons.assignment, iconBgColor: const Color(0xfffef3c7), iconColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: text['reward_events']!, value: '0',
                  subtitle: text['events_subtitle']!,
                  icon: Icons.emoji_events, iconBgColor: const Color(0xfffee2e2), iconColor: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Khối Nội dung chính
          isMobile
              ? Column(
            children: [
              _buildActiveRequests(text['active_requests']!, text['no_active_reports']!),
              const SizedBox(height: 24),
              _buildRecentActivity(text['recent_activity']!, text['no_activity_yet']!),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildActiveRequests(text['active_requests']!, text['no_active_reports']!)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildRecentActivity(text['recent_activity']!, text['no_activity_yet']!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRequests(String title, String content) {
    return _buildSectionBox(
      title: title,
      child: Container(
        height: 160,
        alignment: Alignment.topLeft,
        child: Text(content, style: const TextStyle(color: Color(0xff475569), fontSize: 15)),
      ),
    );
  }

  Widget _buildRecentActivity(String title, String content) {
    return _buildSectionBox(
      title: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff0fdf4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffbbf7d0)),
        ),
        child: Center(
          child: Text(
            content,
            style: const TextStyle(color: Color(0xff10b981), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBox({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffe2e8f0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01), // Đã sửa lại để tương thích mọi bản Flutter
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}