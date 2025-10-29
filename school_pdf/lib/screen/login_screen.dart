import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_unit.dart';
import '../constants/app_colors.dart';
import '../services/referral_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  bool _isTopBannerAdLoaded = false;
  bool _isBottomBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTopBannerAd();
    _loadBottomBannerAd();
  }

  void _loadTopBannerAd() {
    _topBannerAd = BannerAd(
      adUnitId: AdUnit.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isTopBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: AdUnit.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
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
        'subscription': AdUnit.freeSubscriptionType,
        'subscriptionExpiry': null,
        'createdAt': FieldValue.serverTimestamp(),
        'referralCount': 0,
        'referralRewards': 0,
        'referralCode': referralCode,
        'phoneNumber': _phoneNumberController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // Apply referral code if provided
      // final referralInput = _referralCodeController.text.trim();
      // if (referralInput.isNotEmpty && _isValidReferralCode) {
      //   try {
      //     await ReferralService.applyReferralCode(referralInput, uid);
      //     if (mounted) {
      //       _showSuccessDialog(
      //         'Referral code applied successfully! You earned 1 reward point.',
      //       );
      //     }
      //   } catch (e) {
      //     debugPrint('Referral application failed: $e');
      //   }
      // }

      // Send email verification
      // final user = userCredential.user!;

      // await user.sendEmailVerification();

      // Update Firebase user profile
      await userCredential.user!.updateDisplayName(displayName);

      // Show success message
      if (mounted) {
        // Show verification dialog instead of simple success message
        // _showVerificationDialog();

        // Clear the form
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _phoneNumberController.clear();

        // Switch back to sign in mode
        setState(() {
          _isSignUp = false;
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
        child: Column(
          children: [
            // Top Banner Ad
            if (_isTopBannerAdLoaded)
              Container(
                width: double.infinity,
                height: _topBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _topBannerAd!),
              ),
            // Main Content
            Expanded(
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
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
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

                          if (_isSignUp) ...[
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: AppColors.primary),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: AppColors.primary,
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final phoneRegExp = RegExp(r'^[6-9]\d{9}$');
                                  if (!phoneRegExp.hasMatch(value)) {
                                    return 'Enter a valid 10-digit phone number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                          SizedBox(height: 32),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: AppColors.primary),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: AppColors.primary,
                              ),
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
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
                                _phoneNumberController.clear();
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
                          Visibility(
                            visible: !_isSignUp,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
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
            // Bottom Banner Ad
            if (_isBottomBannerAdLoaded)
              Container(
                width: double.infinity,
                height: _bottomBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bottomBannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
