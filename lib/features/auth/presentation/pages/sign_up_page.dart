import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const TextField(decoration: InputDecoration(hintText: '이름')),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(hintText: '이메일'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(hintText: '비밀번호'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
