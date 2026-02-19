import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

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
          'Memo 기능 구현 예정',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
