import 'package:flutter/material.dart';

class DescriptionCard extends StatelessWidget {
  final bool isMobile;
  final TextEditingController controller;
  final String hintText;
  final String title;
  final IconData icon;

  const DescriptionCard({
    super.key,
    required this.isMobile,
    required this.controller,
    this.hintText = 'Mô tả thêm về rác thải...',
    this.title = 'Mô tả chi tiết',
    this.icon = Icons.description,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: const Color(0xFF059669), size: isMobile ? 20 : 22),
        SizedBox(width: isMobile ? 10 : 14),
        Text(title, style: TextStyle(fontSize: isMobile ? 16 : 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
      ]),
      SizedBox(height: isMobile ? 12 : 16),
      TextField(
        controller: controller,
        maxLines: isMobile ? 3 : 4,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF059669), width: 2)),
        ),
      ),
    ]),
  );
}

class SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.isSubmitting, required this.onPressed});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 58,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: ElevatedButton(
      onPressed: isSubmitting ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isSubmitting
          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.send_rounded, size: 22),
              SizedBox(width: 10),
              Text('Gửi Báo Cáo Ngay', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
            ]),
    ),
  );
}
