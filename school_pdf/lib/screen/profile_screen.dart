import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../services/referral_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? referralStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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

  Future<void> _updateSubscription(String subscriptionType) async {
    if (user == null) return;

    // Show payment simulation for non-free subscriptions
    if (subscriptionType != 'free') {
      bool paymentSuccess = await _showPaymentSimulation(subscriptionType);
      if (!paymentSuccess) {
        return; // User cancelled or payment failed
      }
    }

    try {
      DateTime? expiryDate;
      if (subscriptionType != 'free') {
        expiryDate = DateTime.now().add(Duration(days: 30));
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'subscription': subscriptionType,
            'subscriptionExpiry': expiryDate?.toIso8601String(),
          });

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
          builder: (context) =>
              PaymentSimulationDialog(subscriptionType: subscriptionType),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                                  '${userProfile?['subscription']?.toUpperCase() ?? 'FREE'}',
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

                              _buildSubscriptionOption(
                                'Free',
                                'Basic access to files',
                                Icons.info_outline,
                                AppColors.grey600,
                                () => _updateSubscription('free'),
                              ),

                              SizedBox(height: 12),

                              _buildSubscriptionOption(
                                'Premium',
                                'Full access + priority support',
                                Icons.star_outline,
                                AppColors.premium,
                                () => _updateSubscription('premium'),
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
                                              Icons.admin_panel_settings_outlined,
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
      case 'premium':
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
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    bool isCurrentSubscription =
        userProfile?['subscription'] == title.toLowerCase();

    return InkWell(
      onTap: isCurrentSubscription ? null : onTap,
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

  const PaymentSimulationDialog({Key? key, required this.subscriptionType})
    : super(key: key);

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
                          '30 days access to all premium content',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$9.99',
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
