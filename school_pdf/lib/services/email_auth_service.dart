import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'referral_service.dart';

class EmailAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send sign-in link to email (legacy method - kept for compatibility)
  static Future<void> sendSignInLink(String email, {bool isSignUp = false}) async {
    try {
      // Store the email temporarily for later use
      await _firestore
          .collection('pendingEmails')
          .doc(email)
          .set({
            'email': email,
            'isSignUp': isSignUp,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Use a simple URL that will work without Dynamic Links
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://schoolpdf.page.link/auth', // This can be any valid URL
        handleCodeInApp: true,
        iOSBundleId: 'com.example.schoolPdf',
        androidPackageName: 'com.example.school_pdf',
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      log('Sign-in link sent to $email');
    } catch (e) {
      log('Error sending sign-in link: $e');
      rethrow;
    }
  }

  /// NEW METHOD: Create account with email and temporary password
  static Future<void> createAccountWithEmail(String email, String name, {String? referralCode}) async {
    try {
      // Generate a temporary password
      final tempPassword = _generateTempPassword();
      
      // Create user account with email and temporary password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      final uid = userCredential.user!.uid;
      final generatedReferralCode = ReferralService.generateReferralCode();

      // Save user data in Firestore
      final userData = {
        'name': name,
        'email': email,
        'subscription': 'free',
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'referralCount': 0,
        'referralRewards': 0,
        'referralCode': generatedReferralCode,
        'tempPassword': tempPassword, // Store temporarily for email
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData);

      // Apply referral code if provided
      if (referralCode != null && referralCode.isNotEmpty) {
        try {
          await ReferralService.applyReferralCode(referralCode, uid);
          log('Referral code applied successfully for new user');
        } catch (e) {
          log('Failed to apply referral code: $e');
        }
      }

      // Update Firebase user profile
      await userCredential.user!.updateDisplayName(name);

      // Send email with credentials
      await _sendCredentialsEmail(email, tempPassword, name);

      log('Account created successfully for $email');
    } catch (e) {
      log('Error creating account: $e');
      rethrow;
    }
  }

  /// NEW METHOD: Sign in with email and password
  static Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('Sign-in successful for $email');
      log('message: User ID: ${userCredential.user}');
      return userCredential;
    } catch (e) {
      log('Error signing in: $e');
      rethrow;
    }
  }

  /// NEW METHOD: Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log('Password reset email sent to $email');
    } catch (e) {
      log('Error sending password reset: $e');
      rethrow;
    }
  }

  /// Generate temporary password
  static String _generateTempPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    for (int i = 0; i < 12; i++) {
      password += chars[random % chars.length];
    }
    return password;
  }

  /// Send credentials email (simplified - in real app, use email service)
  static Future<void> _sendCredentialsEmail(String email, String password, String name) async {
    // In a real app, you would use a proper email service
    // For now, we'll just log the credentials
    log('CREDENTIALS EMAIL for $email:');
    log('Name: $name');
    log('Email: $email');
    log('Password: $password');
    log('Please save these credentials securely');
  }

  /// Handle email link sign-in (legacy method - kept for compatibility)
  static Future<UserCredential?> handleEmailLink(String emailLink) async {
    try {
      // Check if the link is a valid sign-in link
      if (_auth.isSignInWithEmailLink(emailLink)) {
        // Get the email from pending emails collection
        String? email;
        bool isSignUp = false;
        
        // Try to get email from pending emails
        final pendingEmailsQuery = await _firestore
            .collection('pendingEmails')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
            
        if (pendingEmailsQuery.docs.isNotEmpty) {
          final pendingEmailData = pendingEmailsQuery.docs.first.data();
          email = pendingEmailData['email'] as String?;
          isSignUp = pendingEmailData['isSignUp'] as bool? ?? false;
        }
        
        if (email == null) {
          log('No pending email found, cannot complete sign-in');
          return null;
        }

        // Sign in with email link
        final userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );

        // Clean up pending email
        await _firestore
            .collection('pendingEmails')
            .doc(email)
            .delete();

        // Check if this is a new user (sign-up flow)
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists && isSignUp) {
          // This is a new user, check for pending sign-up data
          final pendingDoc = await _firestore
              .collection('pendingUsers')
              .doc(email)
              .get();

          if (pendingDoc.exists) {
            // Create user data from pending sign-up
            final pendingData = pendingDoc.data()!;
            final userData = {
              'name': pendingData['name'],
              'email': pendingData['email'],
              'subscription': pendingData['subscription'],
              'subscriptionExpiry': pendingData['subscriptionExpiry'],
              'createdAt': FieldValue.serverTimestamp(),
              'referralCount': pendingData['referralCount'],
              'referralRewards': pendingData['referralRewards'],
              'referralCode': pendingData['referralCode'],
            };

            // Save user data
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(userData);

            // Apply referral code if provided
            final referralCodeToApply = pendingData['referralCodeToApply'];
            if (referralCodeToApply != null && referralCodeToApply.isNotEmpty) {
              try {
                await ReferralService.applyReferralCode(
                  referralCodeToApply,
                  userCredential.user!.uid,
                );
                log('Referral code applied successfully for new user');
              } catch (e) {
                log('Failed to apply referral code: $e');
              }
            }

            // Update Firebase user profile
            await userCredential.user!.updateDisplayName(pendingData['name']);

            // Delete pending user data
            await _firestore
                .collection('pendingUsers')
                .doc(email)
                .delete();

            log('New user account created from pending sign-up');
          }
        }

        return userCredential;
      } else {
        log('Invalid email link');
        return null;
      }
    } catch (e) {
      log('Error handling email link: $e');
      rethrow;
    }
  }

  /// Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if email link is valid
  static bool isValidEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  /// Alternative method: Manual email verification (legacy - kept for compatibility)
  static Future<UserCredential?> verifyEmailManually(String email, String link) async {
    try {
      log('Attempting manual email verification for: $email');
      log('Link starts with: ${link.substring(0, link.length > 50 ? 50 : link.length)}...');
      
      if (_auth.isSignInWithEmailLink(link)) {
        log('Link is valid, proceeding with sign-in');
        
        // Check if this is a new user by looking for pending sign-up data
        final pendingDoc = await _firestore
            .collection('pendingUsers')
            .doc(email)
            .get();

        final userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );

        log('Sign-in successful for user: ${userCredential.user?.uid}');

        // If this was a sign-up, create user data
        if (pendingDoc.exists) {
          log('Creating new user account from pending sign-up');
          final pendingData = pendingDoc.data()!;
          final userData = {
            'name': pendingData['name'],
            'email': pendingData['email'],
            'subscription': pendingData['subscription'],
            'subscriptionExpiry': pendingData['subscriptionExpiry'],
            'createdAt': FieldValue.serverTimestamp(),
            'referralCount': pendingData['referralCount'],
            'referralRewards': pendingData['referralRewards'],
            'referralCode': pendingData['referralCode'],
          };

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);

          // Apply referral code if provided
          final referralCodeToApply = pendingData['referralCodeToApply'];
          if (referralCodeToApply != null && referralCodeToApply.isNotEmpty) {
            try {
              await ReferralService.applyReferralCode(
                referralCodeToApply,
                userCredential.user!.uid,
              );
              log('Referral code applied successfully for new user');
            } catch (e) {
              log('Failed to apply referral code: $e');
            }
          }

          // Update Firebase user profile
          await userCredential.user!.updateDisplayName(pendingData['name']);

          // Delete pending user data
          await _firestore
              .collection('pendingUsers')
              .doc(email)
              .delete();

          log('New user account created successfully');
        } else {
          log('Existing user sign-in completed');
        }

        return userCredential;
      } else {
        log('Invalid email link format');
        return null;
      }
    } catch (e) {
      log('Error in manual email verification: $e');
      rethrow;
    }
  }
} 