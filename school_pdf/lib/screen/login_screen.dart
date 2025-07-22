import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../services/referral_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _isValidatingReferral = false;
  bool _isValidReferralCode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _validateReferralCode(String code) async {
    if (code.isEmpty) {
      if (mounted) {
        setState(() {
          _isValidatingReferral = false;
          _isValidReferralCode = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isValidatingReferral = true;
      });
    }

    try {
      final isValid = await ReferralService.isValidReferralCode(code);
      if (mounted) {
        setState(() {
          _isValidatingReferral = false;
          _isValidReferralCode = isValid;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingReferral = false;
          _isValidReferralCode = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Verify user data exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!mounted) return; // Check if widget is still mounted

        if (!userDoc.exists) {
          // If user data doesn't exist, sign out and show error
          await FirebaseAuth.instance.signOut();
          _showErrorDialog('User data not found. Please contact support.');
        } else {
          _showSuccessDialog('Sign in successful!');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return; // Check if widget is still mounted

        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') {
          errorMessage =
              'No account found with this email. Please sign up first.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This account has been disabled.';
        } else if (e.code == 'user-not-verified') {
          errorMessage = 'Please verify your email before signing in.';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        if (!mounted) return; // Check if widget is still mounted

        _showErrorDialog('Something went wrong. Please try again.');
        debugPrint('Sign in error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorDialog('Please enter your email to reset password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSuccessDialog(
          'Password reset email sent! Please check your inbox.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      String errorMessage = 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      _showErrorDialog('Something went wrong. Please try again.');
      debugPrint('Forgot password error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user account
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;
      final displayName = _nameController.text.trim();
      final referralCode = ReferralService.generateReferralCode();

      // Save user data in Firestore
      final userData = {
        'name': displayName,
        'email': _emailController.text.trim(),
        'subscription': 'free',
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'referralCount': 0,
        'referralRewards': 0,
        'referralCode': referralCode,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // Apply referral code if provided
      final referralInput = _referralCodeController.text.trim();
      if (referralInput.isNotEmpty && _isValidReferralCode) {
        try {
          await ReferralService.applyReferralCode(referralInput, uid);
          if (mounted) {
            _showSuccessDialog(
              'Referral code applied successfully! You earned 1 reward point.',
            );
          }
        } catch (e) {
          debugPrint('Referral application failed: $e');
        }
      }

      // Send email verification
      final user = userCredential.user!;

      log('message: Sending verification email to ${user.email}');
      await user.sendEmailVerification();

      // Update Firebase user profile
      await userCredential.user!.updateDisplayName(displayName);

      // Show success message
      if (mounted) {
        // Show verification dialog instead of simple success message
        _showVerificationDialog();

        // Clear the form
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _referralCodeController.clear();

        // Switch back to sign in mode
        setState(() {
          _isSignUp = false;
          _isValidReferralCode = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      String errorMessage = 'An error occurred during sign up.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'An account with this email already exists.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      _showErrorDialog('Something went wrong. Please try again.');
      debugPrint('Sign up error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('No user found. Please sign up first.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await user.sendEmailVerification();
      if (mounted) {
        _showSuccessDialog(
          'Verification email sent! Please check your inbox and click the verification link.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to send verification email. Please try again.');
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showVerificationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.email, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Email Verification',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please verify your email address to complete your registration:',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            SizedBox(height: 12),
            Text(
              '1. Check your email inbox\n2. Click the verification link\n3. Return to the app and sign in',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Didn\'t receive the email?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resendVerificationEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text('Resend Email'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Check if widget is still mounted

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Error', style: TextStyle(color: AppColors.primary)),
        content: Text(message, style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return; // Check if widget is still mounted

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Success', style: TextStyle(color: AppColors.success)),
          ],
        ),
        content: Text(message, style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.0),
            child: Container(
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryShade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_bg.png',
                        height: 100,
                        scale: 1.5,
                        // color: Color.fromARGB(255, 15, 147, 59),
                        // opacity: const AlwaysStoppedAnimation<double>(0.5),
                      ),
                      // Image(
                      //   image:
                      //   AssetImage(
                      //     'assets/images/logo_bg.png',
                      //     height: 100,
                      //     width: 100,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Student Friend',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 32),
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: AppColors.primary),
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppColors.primary),
                        prefixIcon: Icon(Icons.email, color: AppColors.primary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: AppColors.primary),
                        prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    if (_isSignUp) ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _referralCodeController,
                        decoration: InputDecoration(
                          labelText: 'Referral Code (Optional)',
                          labelStyle: TextStyle(color: AppColors.primary),
                          prefixIcon: Icon(
                            Icons.card_giftcard,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _isValidatingReferral
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : _referralCodeController.text.isNotEmpty
                              ? Icon(
                                  _isValidReferralCode
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _isValidReferralCode
                                      ? AppColors.success
                                      : AppColors.error,
                                )
                              : null,
                          helperText:
                              'Enter a friend\'s referral code to earn rewards',
                          helperStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _validateReferralCode(value);
                          } else {
                            setState(() {
                              _isValidReferralCode = false;
                            });
                          }
                        },
                      ),
                      if (_referralCodeController.text.isNotEmpty &&
                          !_isValidatingReferral) ...[
                        SizedBox(height: 8),
                        Text(
                          _isValidReferralCode
                              ? '✓ Valid referral code! You\'ll earn 1 reward point.'
                              : '✗ Invalid referral code',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isValidReferralCode
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isSignUp ? _signUp : _signIn),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.shadowMedium,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Sign Up' : 'Sign In',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _referralCodeController.clear();
                          _isValidReferralCode = false;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign In'
                            : 'Don\'t have an account? Sign Up',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // SizedBox(height: 8),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
