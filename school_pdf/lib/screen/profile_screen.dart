import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ad_unit.dart';
import '../constants/app_colors.dart';
import '../services/referral_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
  String? _promoCodeError;
  String? _referralCodeError;
  int _subscriptionPrice = 150;
  bool _isCheckingPromo = false;
  bool _isCheckingReferral = false;
  final int eligibleCount = 2;

  // In-App Purchase variables
  final String _premiumProductId =
      'premium_subscription'; // Replace with your real product ID
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _iapSubscription;
  bool _iapAvailable = false;
  bool _iapLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initInAppPurchase();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    _referralCodeController.dispose();
    _iapSubscription?.cancel();
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

    // Prevent paid subscription if eligible for free
    final activeList = referralStats?['activeReferredUserList'] as List?;

    // Show payment simulation for non-free subscriptions
    if (subscriptionType != AdUnit.freeSubscriptionType &&
        activeList != null &&
        activeList.length >= eligibleCount &&
        subscriptionType != AdUnit.freeSubscriptionType) {
      bool paymentSuccess = await _showPaymentSimulation(subscriptionType);
      if (!paymentSuccess) {
        return; // User cancelled or payment failed
      }
    }
    try {
      DateTime? expiryDate;
      if (subscriptionType != AdUnit.freeSubscriptionType) {
        expiryDate = DateTime.now().add(Duration(days: 730)); // 2 years
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'subscription': subscriptionType,
            'subscriptionExpiry': expiryDate?.toIso8601String(),
          });

      if (subscriptionType != AdUnit.freeSubscriptionType && !isClaim) {
        if (userProfile?['referredBy'] != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userProfile?['referredBy'])
              .update({
                'activeReferredUserList': FieldValue.arrayUnion([user!.uid]),
              });
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
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentSimulationDialog(
            subscriptionType: subscriptionType,
            price: _subscriptionPrice,
          ),
        ) ??
        false;
  }

  Future<void> _checkPromoCode(String code) async {
    setState(() {
      _isCheckingPromo = true;
      _promoCodeError = null;
    });

    final promoSnap = await FirebaseFirestore.instance
        .collection('promocodes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    // log('message ${promoSnap.data}');
    if (promoSnap.docs.isNotEmpty) {
      setState(() {
        _subscriptionPrice = 50;
      });
    } else {
      setState(() {
        _promoCodeError = 'Invalid promo code';
        _subscriptionPrice = 150;
      });
    }
    setState(() {
      _isCheckingPromo = false;
    });
  }

  Future<void> _checkReferralCode(String code) async {
    setState(() {
      _isCheckingReferral = true;
      _referralCodeError = null;
    });
    final isValid = await ReferralService.isValidReferralCode(code);
    if (isValid) {
      setState(() {
        if (_subscriptionPrice > 100) _subscriptionPrice = 100;
      });
    } else {
      setState(() {
        _referralCodeError = 'Invalid referral code';
        _subscriptionPrice = 150;
      });
    }
    setState(() {
      _isCheckingReferral = false;
    });
  }

  Future<void> _initInAppPurchase() async {
    setState(() {
      _iapLoading = true;
    });
    final bool available = await InAppPurchase.instance.isAvailable();
    setState(() {
      _iapAvailable = available;
    });
    if (!available) {
      setState(() {
        _iapLoading = false;
      });
      return;
    }
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({_premiumProductId});
    if (response.notFoundIDs.isEmpty) {
      setState(() {
        _products = response.productDetails;
      });
    }
    _iapSubscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdated,
    );
    setState(() {
      _iapLoading = false;
    });
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Optionally verify purchase here
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
              'subscription': AdUnit.premiumSubscriptionType,
              'subscriptionExpiry': DateTime.now()
                  .add(Duration(days: 30))
                  .toIso8601String(),
            });
        _loadUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Premium unlocked!'),
            backgroundColor: AppColors.success,
          ),
        );
        InAppPurchase.instance.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _buyPremium() async {
    if (!_iapAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('In-app purchases not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Premium product not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final product = _products.firstWhere((p) => p.id == _premiumProductId);
    final purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eligibleForFree =
        (referralStats?['activeReferredUserList'] as List?)?.length != null &&
        (referralStats?['activeReferredUserList'] as List).length >=
            eligibleCount;
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
                                      '${referralStats?['activeReferredUserList'].length ?? 0}',
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
                              if (userProfile?['subscriptionExpiry'] !=
                                  null) ...[
                                SizedBox(height: 12),
                                Text(
                                  'Expires: ${DateTime.parse(userProfile!['subscriptionExpiry']).toString().substring(0, 10)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Subscription Plans
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
                              Text(
                                'Apply Referral or Promo Code for Discount',
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _promoCodeController,

                                decoration: InputDecoration(
                                  labelText: 'Promo Code',
                                  errorText: _promoCodeError,
                                  suffixIcon: _isCheckingPromo
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(Icons.check),
                                          onPressed: () => _checkPromoCode(
                                            _promoCodeController.text.trim(),
                                          ),
                                        ),
                                ),
                                onChanged: (v) {
                                  if (v.isEmpty) {
                                    setState(() {
                                      _promoCodeError = null;
                                      _subscriptionPrice = 150;
                                    });
                                  } else {
                                    _checkPromoCode(v.trim());
                                  }
                                },
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _referralCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Referral Code',
                                  errorText: _referralCodeError,
                                  suffixIcon: _isCheckingReferral
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(Icons.check),
                                          onPressed: () => _checkReferralCode(
                                            _referralCodeController.text.trim(),
                                          ),
                                        ),
                                ),
                                onChanged: (v) {
                                  if (v.isEmpty) {
                                    setState(() {
                                      _referralCodeError = null;
                                      _subscriptionPrice = 150;
                                    });
                                  } else {
                                    _checkReferralCode(
                                      _referralCodeController.text.trim(),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Subscription Price: ₹$_subscriptionPrice (lifetime)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 12),

                              _buildSubscriptionOption(
                                AdUnit.freeSubscriptionType,
                                eligibleForFree
                                    ? 'Unlocked! You have more than 5 active referrals.'
                                    : 'Basic access to files',
                                Icons.info_outline,
                                AppColors.grey600,
                                () => _updateSubscription(
                                  AdUnit.freeSubscriptionType,
                                  false,
                                ),
                              ),

                              if (eligibleForFree &&
                                  userProfile?['subscription'] !=
                                      AdUnit.premiumSubscriptionType) ...[
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateSubscription(
                                      AdUnit.premiumSubscriptionType,
                                      true,
                                    ),
                                    icon: Icon(Icons.card_giftcard),
                                    label: Text('Claim Free Subscription'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 12),

                              _buildSubscriptionOption(
                                AdUnit.premiumSubscriptionType,
                                'Full access + priority support',
                                Icons.star_outline,
                                AppColors.premium,

                                !isFree
                                    ? null
                                    : () =>
                                          _updateSubscription(AdUnit.premiumSubscriptionType, false),
                              ),

                              SizedBox(height: 12),

                              // _buildSubscriptionOption(
                              //   'Pro',
                              //   'All features + advanced analytics',
                              //   Icons.diamond_outlined,
                              //   Colors.purple,
                              //   () => _updateSubscription('pro'),
                              // ),
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
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pushNamed(context, '/');
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

    log('asssss ${userProfile?['subscription']}');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            if (!isCurrentSubscription)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class PaymentSimulationDialog extends StatefulWidget {
  final String subscriptionType;
  final int price; // Add this

  const PaymentSimulationDialog({
    Key? key,
    required this.subscriptionType,
    required this.price,
  }) : super(key: key);

  @override
  State<PaymentSimulationDialog> createState() =>
      _PaymentSimulationDialogState();
}

class _PaymentSimulationDialogState extends State<PaymentSimulationDialog> {
  bool isProcessing = false;
  bool isSuccess = false;
  bool isFailed = false;
  String currentStep = 'initial';

  @override
  void initState() {
    super.initState();
    _startPaymentProcess();
  }

  Future<void> _startPaymentProcess() async {
    setState(() {
      isProcessing = true;
      currentStep = 'processing';
    });

    // Simulate payment processing steps
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      currentStep = 'validating';
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      currentStep = 'charging';
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      currentStep = 'confirming';
    });

    await Future.delayed(Duration(seconds: 1));

    // Simulate 90% success rate
    bool success = DateTime.now().millisecond % 10 < 9; // 90% success rate

    setState(() {
      isProcessing = false;
      if (success) {
        isSuccess = true;
        currentStep = 'success';
      } else {
        isFailed = true;
        currentStep = 'failed';
      }
    });

    // Auto close after showing result
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  String _getStepMessage() {
    switch (currentStep) {
      case 'processing':
        return 'Initializing payment...';
      case 'validating':
        return 'Validating payment method...';
      case 'charging':
        return 'Processing payment...';
      case 'confirming':
        return 'Confirming transaction...';
      case 'success':
        return 'Payment successful!';
      case 'failed':
        return 'Payment failed. Please try again.';
      default:
        return 'Processing...';
    }
  }

  IconData _getStepIcon() {
    switch (currentStep) {
      case 'processing':
      case 'validating':
      case 'charging':
      case 'confirming':
        return Icons.payment;
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.payment;
    }
  }

  Color _getStepColor() {
    switch (currentStep) {
      case 'processing':
      case 'validating':
      case 'charging':
      case 'confirming':
        return AppColors.primary;
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Payment Simulation',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Subscription Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryShade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.premium.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.star, color: AppColors.premium, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.subscriptionType.toUpperCase()} Subscription',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Life Time access to all premium content',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${widget.price}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Payment Status
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStepColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStepColor().withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  if (isProcessing)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStepColor(),
                      ),
                    )
                  else
                    Icon(_getStepIcon(), size: 48, color: _getStepColor()),
                  SizedBox(height: 16),
                  Text(
                    _getStepMessage(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getStepColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons
            if (isFailed)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isProcessing = false;
                          isSuccess = false;
                          isFailed = false;
                          currentStep = 'initial';
                        });
                        _startPaymentProcess();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ),
                ],
              )
            else if (!isProcessing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(isSuccess),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(isSuccess ? 'Continue' : 'OK'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
