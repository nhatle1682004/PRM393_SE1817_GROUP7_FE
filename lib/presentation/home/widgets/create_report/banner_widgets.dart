import 'package:flutter/material.dart';

class MobileHeaderBanner extends StatelessWidget {
  const MobileHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BÁO CÁO RÁC THẢI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tải ảnh & chọn vị trí để nhận thưởng',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          SizedBox(height: 10),
          _RewardBadgeMobile(),
        ],
      ),
    );
  }
}

class _RewardBadgeMobile extends StatelessWidget {
  const _RewardBadgeMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
          SizedBox(width: 6),
          Text(
            '+10 Điểm Xanh',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DesktopHeaderBanner extends StatelessWidget {
  const DesktopHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final imageSize = isNarrow ? constraints.maxWidth * 0.25 : 140.0;
        final titleSize = isNarrow ? 18.0 : 26.0;
        final subtitleSize = isNarrow ? 12.0 : 14.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 16 : 24),
          margin: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isNarrow
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                      ).createShader(bounds),
                      child: Text(
                        "BÁO CÁO RÁC THẢI VÌ CỘNG ĐỒNG",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tải ảnh & chọn vị trí để nhận thưởng",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: subtitleSize, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    RewardBadge(fontSize: subtitleSize),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: imageSize,
                        height: 140,
                        child: Image.asset(
                          'assets/images/3d_report_illustration.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(child: Icon(Icons.image, size: 40, color: Color(0xFF10B981))),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ).createShader(bounds),
                            child: Text(
                              "BÁO CÁO RÁC THẢI VÌ CỘNG ĐỒNG",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: isNarrow ? 10 : 14),
                          Text(
                            "Vui lòng tải lên hình ảnh bãi rác tự phát và chọn vị trí chính xác để đội ngũ thu gom xử lý.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: subtitleSize, color: Colors.grey.shade600, height: 1.5),
                          ),
                          SizedBox(height: isNarrow ? 12 : 18),
                          RewardBadge(fontSize: subtitleSize),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class RewardBadge extends StatelessWidget {
  final double fontSize;

  const RewardBadge({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 1.3, vertical: fontSize * 0.85),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: const Color(0xFFFBBF24), size: fontSize * 1.5),
          SizedBox(width: fontSize * 0.5),
          Text("Thưởng ngay: ", style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
            ).createShader(bounds),
            child: Text("+10 Điểm Xanh", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          Text(" sau khi xác thực!", style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
