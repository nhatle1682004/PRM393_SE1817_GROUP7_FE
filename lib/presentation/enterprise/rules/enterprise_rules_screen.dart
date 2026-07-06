import 'package:flutter/material.dart';

class EnterpriseRulesScreen extends StatelessWidget {
  const EnterpriseRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Quy tắc điều phối: chỉ accept report thuộc district quản lý, phân công collector khả dụng, theo dõi request/assignment cho đến khi hoàn tất.',
          ),
        ),
      ),
    );
  }
}
