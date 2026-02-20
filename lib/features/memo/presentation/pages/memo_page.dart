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
            icon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_note_rounded, size: 52, color: AppColors.textDisabled),
              SizedBox(height: 16),
              Text(
                '메모가 없습니다',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '아래 + 버튼으로\n첫 번째 메모를 작성해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 13,
                  letterSpacing: -0.1,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
