import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const Spacer(flex: 2),
              _buildLoginCard(context),
              const SizedBox(height: 24),
              _buildFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'SENT',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '일상을 체계적으로 관리하세요',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '소셜 계정으로 간편하게 시작하세요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          _SocialLoginButton(
            label: 'Google로 계속하기',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: _GoogleIcon(),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _SocialLoginButton(
            label: '네이버로 계속하기',
            backgroundColor: const Color(0xFF03C75A),
            foregroundColor: Colors.white,
            icon: const Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _SocialLoginButton(
            label: '카카오로 계속하기',
            backgroundColor: const Color(0xFFFEE500),
            foregroundColor: const Color(0xFF191919),
            icon: const Icon(Icons.chat_bubble, color: Color(0xFF191919), size: 20),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      '계속 진행하면 서비스 약관과 개인정보 처리방침에\n동의하는 것으로 간주됩니다.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
        height: 1.6,
        letterSpacing: -0.1,
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(width: 24, child: Center(child: icon)),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
