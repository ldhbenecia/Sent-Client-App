import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Social 기능 구현 예정',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
