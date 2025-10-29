import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_unit.dart';
import '../constants/app_colors.dart';
import '../services/referral_service.dart';
import '../services/payment_service.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? referralStats;
  bool isLoading = true;
  final TextEditingController _promoCodeController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  final FocusNode _promoCodeFocusNode = FocusNode();
  final FocusNode _referralCodeFocusNode = FocusNode();

  String? _promoCodeError;
  String? _referralCodeError;
  int _subscriptionPrice = AdUnit.subscriptionPrice;

  // bool _isCheckingPromo = false;
  // bool _isCheckingReferral = false;
  // final int _eligibleCount = AdUnit.eligibleCount;

  bool _isReferralCodeValid = false;
  bool _isPromoCodeValid = false;
  
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  // bool _isTopBannerAdLoaded = false;
  // bool _isBottomBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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
            // _isTopBannerAdLoaded = true;
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
            // _isBottomBannerAdLoaded = true;
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
    _promoCodeController.dispose();
    _referralCodeController.dispose();
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userProfile = doc.data() as Map<String, dynamic>;
          });
        }

        // Load referral stats
        try {
          final stats = await ReferralService.getUserReferralStats();
          setState(() {
            referralStats = stats;
          });
        } catch (e) {
          print('Failed to load referral stats: $e');
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Error loading profile: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSubscription(
    String subscriptionType,
    bool isClaim,
  ) async {
    if (user == null) return;

    // Show payment simulation for non-free subscriptions
    if (subscriptionType != AdUnit.freeSubscriptionType && !isClaim) {
      bool paymentSuccess = await _showPaymentSimulation(subscriptionType);
      if (!paymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed'),
            backgroundColor: AppColors.error,
          ),
        );
        return; // User cancelled or payment failed
      }
    }
    try {
      DateTime? expiryDate;
      if (subscriptionType != AdUnit.freeSubscriptionType) {
        expiryDate = DateTime.now().add(
          Duration(days: AdUnit.eligibleCount),
        ); // 2 years
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'subscription': subscriptionType,
            'subscriptionExpiry': expiryDate?.toIso8601String(),
            'subscriptionPrice': _subscriptionPrice,
            'adFree': true,
          });

      if (subscriptionType != AdUnit.freeSubscriptionType) {
        // if (userProfile?['referredBy'] != null) {
        //   await FirebaseFirestore.instance
        //       .collection('users')
        //       .doc(userProfile?['referredBy'])
        //       .update({
        //         'activeReferredUserList': FieldValue.arrayUnion([user!.uid]),
        //       });
        // }
        if (_isReferralCodeValid && _referralCodeController.text.trim() != '') {
          await ReferralService.applyReferralCode(
            _referralCodeController.text,
            user!.uid,
          );
        }
        if (_isPromoCodeValid && _promoCodeController.text.trim() != '') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'promoCode': _promoCodeController.text.trim()});
        }
      }

      _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscription updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update subscription'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showPaymentSimulation(String subscriptionType) async {
    try {
      final result = await PaymentService.startPayment(
        context: context,
        amount: _subscriptionPrice,
        subscriptionType: subscriptionType,
        preferredMethod: PaymentMethod.upi,
      );

      return result.success;
    } catch (e) {
      log('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
  }

  void _showPremiumPurchaseSheet() {
    // Reset controllers and validation states
    _promoCodeController.clear();
    _referralCodeController.clear();
    _isPromoCodeValid = false;
    _isReferralCodeValid = false;
    _promoCodeError = null;
    _referralCodeError = null;
    _subscriptionPrice = AdUnit.subscriptionPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.premium.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.star,
                              color: AppColors.premium,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Premium Plan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                Text(
                                  'Lifetime access to all features',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Price Display
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.premium.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.premium.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹$_subscriptionPrice',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _subscriptionPrice <
                                                AdUnit.subscriptionPrice
                                            ? AppColors.success
                                            : AppColors.premium,
                                      ),
                                ),
                                SizedBox(width: 12),
                                if (_subscriptionPrice <
                                    AdUnit.subscriptionPrice) ...[
                                  Text(
                                    '₹${AdUnit.subscriptionPrice}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'SAVE ₹${AdUnit.subscriptionPrice - _subscriptionPrice}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Promo Code Section
                      Text(
                        'Apply Promo Code',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 20
                              : 0,
                        ),
                        child: TextField(
                          focusNode: _promoCodeFocusNode,
                          controller: _promoCodeController,
                          decoration: InputDecoration(
                            labelText: 'Enter promo code',
                            errorText: _promoCodeError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () => _applyPromoCode(
                                _promoCodeController.text.trim(),
                              ),
                            ),
                            // suffixIcon: _isCheckingPromo
                            //     ? Padding(
                            //         padding: EdgeInsets.all(12),
                            //         child: SizedBox(
                            //           width: 20,
                            //           height: 20,
                            //           child: CircularProgressIndicator(
                            //             strokeWidth: 2,
                            //             valueColor:
                            //                 AlwaysStoppedAnimation<Color>(
                            //                   AppColors.primary,
                            //                 ),
                            //           ),
                            //         ),
                            //       )
                            //     : _isPromoCodeValid
                            //     ? Icon(
                            //         Icons.check_circle,
                            //         color: AppColors.success,
                            //       )
                            //     : IconButton(
                            //         icon: Icon(Icons.check),
                            //         onPressed: () => _checkPromoCode(
                            //           _promoCodeController.text.trim(),
                            //         ),
                            //       ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _promoCodeError = null;
                                _isPromoCodeValid = false;
                                _updateSubscriptionPrice();
                              });
                            } else {
                              _checkPromoCode(value.trim());
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 16),

                      // Referral Code Section
                      Text(
                        'Apply Referral Code',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        focusNode: _referralCodeFocusNode,
                        controller: _referralCodeController,
                        decoration: InputDecoration(
                          labelText: 'Enter referral code',
                          errorText: _referralCodeError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.all(16),
                          suffix: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () => _applyReferralCode(
                              _referralCodeController.text.trim(),
                            ),
                          ),
                          // suffixIcon: _isCheckingReferral
                          //     ? Padding(
                          //         padding: EdgeInsets.all(12),
                          //         child: SizedBox(
                          //           width: 20,
                          //           height: 20,
                          //           child: CircularProgressIndicator(
                          //             strokeWidth: 2,
                          //             valueColor: AlwaysStoppedAnimation<Color>(
                          //               AppColors.primary,
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //     : _isReferralCodeValid
                          //     ? Icon(
                          //         Icons.check_circle,
                          //         color: AppColors.success,
                          //       )
                          //     : IconButton(
                          //         icon: Icon(Icons.check),
                          //         onPressed:
                          //             _referralCodeController.text.isNotEmpty
                          //             ? () => _checkReferralCode(
                          //                 _referralCodeController.text.trim(),
                          //               )
                          //             : null,
                          //       ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              _referralCodeError = null;
                              _isReferralCodeValid = false;
                              _updateSubscriptionPrice();
                            });
                          } else {
                            _checkReferralCode(value.trim());
                          }
                        },
                      ),

                      SizedBox(height: 24),

                      // Pay Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateSubscription(
                              AdUnit.premiumSubscriptionType,
                              false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.premium,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Pay ₹$_subscriptionPrice',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyPromoCode(String code) async {
    // Close keyboard

    _promoCodeFocusNode.unfocus();

    // Add a small delay to ensure keyboard closes before proceeding
    await Future.delayed(Duration(milliseconds: 100));

    _checkPromoCode(code);
  }

  Future<void> _checkPromoCode(String code) async {
    setState(() {
      // _isCheckingPromo = true;
      _promoCodeError = null;
    });

    final promoSnap = await FirebaseFirestore.instance
        .collection('promocodes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (promoSnap.docs.isNotEmpty) {
      setState(() {
        _isPromoCodeValid = true;
        _updateSubscriptionPrice();
      });
    } else {
      setState(() {
        _promoCodeError = 'Invalid promo code';
        _isPromoCodeValid = false;
        _updateSubscriptionPrice();
      });
    }

    setState(() {
      // _isCheckingPromo = false;
    });
  }

  Future<void> _applyReferralCode(String code) async {
    _referralCodeFocusNode.unfocus();
    // await Future.delayed(Duration(milliseconds: 100));
    _checkReferralCode(code);
  }

  Future<void> _checkReferralCode(String code) async {
    setState(() {
      // _isCheckingReferral = true;
      _referralCodeError = null;
    });

    final isValid = await ReferralService.isValidReferralCode(code);

    if (isValid) {
      setState(() {
        _isReferralCodeValid = true;
        _updateSubscriptionPrice();
      });
    } else {
      setState(() {
        _referralCodeError = 'Invalid referral code';
        _isReferralCodeValid = false;
        _updateSubscriptionPrice();
      });
    }

    setState(() {
      // _isCheckingReferral = false;
    });
  }

  // String _getDiscountMessage() {
  //   if (_isPromoCodeValid && _isReferralCodeValid) {
  //     return 'Promo code and referral code applied successfully!';
  //   } else if (_isPromoCodeValid) {
  //     return 'Promo code applied successfully!';
  //   } else if (_isReferralCodeValid) {
  //     return 'Referral code applied successfully!';
  //   }
  //   return '';
  // }

  void _updateSubscriptionPrice() {
    int newPrice = AdUnit.subscriptionPrice;

    if (_isPromoCodeValid) {
      newPrice = AdUnit.promoSubscriptionPrice;
    }

    if (_isReferralCodeValid && AdUnit.referralSubscriptionPrice < newPrice) {
      newPrice = AdUnit.referralSubscriptionPrice;
    }

    setState(() {
      _subscriptionPrice = newPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isFree = userProfile?['subscription'] == AdUnit.freeSubscriptionType;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowMedium,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          userProfile?['name'] ?? 'User',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userProfile?['email'] ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Referral Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.referral.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: AppColors.referral,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Referral Program',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildReferralStat(
                                      'Referrals',
                                      '${referralStats?['referralCount'] ?? 0}',
                                      AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildReferralStat(
                                      'Rewards',
                                      '${referralStats?['referralRewards'] ?? 0}',
                                      AppColors.premium,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/referrals');
                                  },
                                  icon: Icon(Icons.share),
                                  label: Text('View Referrals'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.referral,
                                    foregroundColor: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Subscription Status
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.card_membership,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Subscription Status',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSubscriptionColor(
                                    userProfile?['subscription'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getSubscriptionColor(
                                      userProfile?['subscription'],
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${userProfile?['subscription']?.toUpperCase() ?? AdUnit.freeSubscriptionType}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getSubscriptionColor(
                                      userProfile?['subscription'],
                                    ),
                                  ),
                                ),
                              ),
                              // if (userProfile?['subscriptionExpiry'] !=
                              //     null) ...[
                              // SizedBox(height: 12),
                              // Text(
                              //   'Expires: ${DateTime.parse(userProfile!.subscriptionExpiry).toString().substring(0, 10)}',
                              //   style: theme.textTheme.bodyMedium?.copyWith(
                              //     color: AppColors.textSecondary,
                              //   ),
                              // ),
                              // ],
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Subscription Plans
                        // Updated Subscription Plans Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.upgrade,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Subscription Plans',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Pricing Display Card
                              // Container(
                              //   width: double.infinity,
                              //   padding: EdgeInsets.all(16),
                              //   decoration: BoxDecoration(
                              //     gradient: LinearGradient(
                              //       colors: [
                              //         AppColors.primary.withOpacity(0.1),
                              //         AppColors.secondary.withOpacity(0.1),
                              //       ],
                              //       begin: Alignment.topLeft,
                              //       end: Alignment.bottomRight,
                              //     ),
                              //     borderRadius: BorderRadius.circular(12),
                              //     border: Border.all(
                              //       color: AppColors.primary.withOpacity(0.2),
                              //     ),
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           Icon(
                              //             Icons.local_offer,
                              //             color: AppColors.primary,
                              //             size: 20,
                              //           ),
                              //           SizedBox(width: 8),
                              //           Text(
                              //             'Premium Lifetime Plan',
                              //             style: theme.textTheme.titleLarge
                              //                 ?.copyWith(
                              //                   fontWeight: FontWeight.bold,
                              //                   color: AppColors.primary,
                              //                 ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 12),

                              //       // Price Display
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.end,
                              //         children: [
                              //           // Current Price
                              //           Text(
                              //             '₹$_subscriptionPrice',
                              //             style: theme.textTheme.headlineMedium
                              //                 ?.copyWith(
                              //                   fontWeight: FontWeight.bold,
                              //                   color:
                              //                       _subscriptionPrice <
                              //                           AdUnit.subscriptionPrice
                              //                       ? AppColors.success
                              //                       : AppColors.textPrimary,
                              //                 ),
                              //           ),
                              //           SizedBox(width: 8),

                              //           // Original Price (crossed out if discounted)
                              //           if (_subscriptionPrice <
                              //               AdUnit.subscriptionPrice) ...[
                              //             Text(
                              //               '₹${AdUnit.subscriptionPrice}',
                              //               style: theme.textTheme.titleMedium
                              //                   ?.copyWith(
                              //                     decoration: TextDecoration
                              //                         .lineThrough,
                              //                     color:
                              //                         AppColors.textSecondary,
                              //                     fontWeight: FontWeight.w400,
                              //                   ),
                              //             ),
                              //             SizedBox(width: 8),
                              //             Container(
                              //               padding: EdgeInsets.symmetric(
                              //                 horizontal: 8,
                              //                 vertical: 4,
                              //               ),
                              //               decoration: BoxDecoration(
                              //                 color: AppColors.success,
                              //                 borderRadius:
                              //                     BorderRadius.circular(12),
                              //               ),
                              //               child: Text(
                              //                 'SAVE ₹${AdUnit.subscriptionPrice - _subscriptionPrice}',
                              //                 style: theme.textTheme.labelSmall
                              //                     ?.copyWith(
                              //                       color: AppColors.white,
                              //                       fontWeight: FontWeight.bold,
                              //                     ),
                              //               ),
                              //             ),
                              //           ],
                              //         ],
                              //       ),

                              //       SizedBox(height: 4),
                              //       Text(
                              //         'One-time payment • Lifetime access',
                              //         style: theme.textTheme.bodyMedium
                              //             ?.copyWith(
                              //               color: AppColors.textSecondary,
                              //             ),
                              //       ),

                              //       // Discount Information
                              //       if (_subscriptionPrice <
                              //           AdUnit.subscriptionPrice) ...[
                              //         SizedBox(height: 12),
                              //         Container(
                              //           padding: EdgeInsets.all(12),
                              //           decoration: BoxDecoration(
                              //             color: AppColors.success.withOpacity(
                              //               0.1,
                              //             ),
                              //             borderRadius: BorderRadius.circular(
                              //               8,
                              //             ),
                              //             border: Border.all(
                              //               color: AppColors.success
                              //                   .withOpacity(0.3),
                              //             ),
                              //           ),
                              //           child: Row(
                              //             children: [
                              //               Icon(
                              //                 Icons.check_circle,
                              //                 color: AppColors.success,
                              //                 size: 20,
                              //               ),
                              //               SizedBox(width: 8),
                              //               Expanded(
                              //                 child: Text(
                              //                   _getDiscountMessage(),
                              //                   style: theme
                              //                       .textTheme
                              //                       .bodyMedium
                              //                       ?.copyWith(
                              //                         color: AppColors.success,
                              //                         fontWeight:
                              //                             FontWeight.w500,
                              //                       ),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ],
                              //     ],
                              //   ),
                              // ),

                              // SizedBox(height: 20),

                              // Subscription Options
                              _buildSubscriptionOption(
                                AdUnit.freeSubscriptionType,
                                'Basic access to files',
                                Icons.info_outline,
                                AppColors.grey600,
                                () {},
                              ),

                              SizedBox(height: 12),

                              _buildSubscriptionOption(
                                AdUnit.premiumSubscriptionType,
                                'Full access + priority support',
                                Icons.star_outline,
                                AppColors.premium,
                                !isFree
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Already subscribed'),
                                            backgroundColor:
                                                AppColors.secondary,
                                          ),
                                        );
                                      }
                                    : () => _showPremiumPurchaseSheet(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Account Actions
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.settings,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Account Actions',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final shouldSignOut = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Logout'),
                                          content: const Text(
                                            'Are you sure you want to sign out?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                false,
                                              ), // Cancel
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                true,
                                              ), // Confirm
                                              child: const Text('Sign Out'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldSignOut == true) {
                                        await FirebaseAuth.instance.signOut();
                                        if (context.mounted) {
                                          setState(() {
                                            userProfile = null;
                                            referralStats = null;
                                          });
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/',
                                          );
                                        }
                                      }
                                    },

                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(
                                          0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.error.withOpacity(
                                            0.2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            color: AppColors.error,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Sign Out',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),

                                  Visibility(
                                    visible: userProfile?['isAdmin'] ?? false,
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.pushNamed(context, '/admin');
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(
                                            0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.error.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .admin_panel_settings_outlined,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Admin Panel',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReferralStat(String title, String value, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(String? subscription) {
    switch (subscription) {
      case AdUnit.premiumSubscriptionType:
        return AppColors.premium;
      case 'pro':
        return AppColors.secondary;
      default:
        return AppColors.grey600;
    }
  }

  Widget _buildSubscriptionOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    bool isCurrentSubscription = userProfile?['subscription'] == title;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentSubscription
            ? color.withOpacity(0.1)
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSubscription ? color : AppColors.border,
          width: isCurrentSubscription ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isCurrentSubscription ? color : AppColors.textSecondary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCurrentSubscription
                            ? color
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isCurrentSubscription) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Current',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentSubscription && title == AdUnit.premiumSubscriptionType)
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Buy',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            )
          else if (!isCurrentSubscription)
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
        ],
      ),
    );
  }
}
