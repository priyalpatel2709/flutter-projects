import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  Future<void> resendVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📧 Please verify: ${user?.email}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resendVerification,
              child: const Text("Resend Verification Email"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: reloadUser,
              child: const Text("I Verified, Refresh"),
            ),
            const Text("Waiting for email verification..."),
          ],
        ),
      ),
    );
  }
}
