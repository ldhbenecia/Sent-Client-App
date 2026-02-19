import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Sent',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '생산성을 한 곳에서',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Spacer(),
              TextField(
                decoration: const InputDecoration(hintText: '이메일'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(hintText: '비밀번호'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/todo'),
                child: const Text('로그인'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/auth/sign-up'),
                  child: const Text('회원가입'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
