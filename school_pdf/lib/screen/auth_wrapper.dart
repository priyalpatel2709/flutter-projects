import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }

        final user = snapshot.data;
        
        if (user != null) {
          // Reload user to get latest email verification status
          user.reload();
          log('message: User email verified: ${user.emailVerified}');
          
          // Check if email is verified
          if (!user.emailVerified) {
            // User is signed in but email is not verified
            // Sign them out and show login screen
            FirebaseAuth.instance.signOut();
            return LoginScreen();
          }

          // Check if user data exists in Firestore before redirecting
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, firestoreSnapshot) {
              if (firestoreSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }

              // If user data doesn't exist in Firestore, stay on login screen
              if (!firestoreSnapshot.hasData ||
                  !firestoreSnapshot.data!.exists) {
                return LoginScreen();
              }

              // User is verified and data exists, safe to redirect to home screen
              return HomeScreen();
            },
          );
        }

        return LoginScreen();
      },
    );
  }
}
