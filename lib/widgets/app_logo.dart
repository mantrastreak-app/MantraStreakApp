import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.appIcon,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_fire_department,
          color: AppColors.white.withOpacity(0.9),
          size: size * 0.45,
        ),
      ),
    );
  }
}
