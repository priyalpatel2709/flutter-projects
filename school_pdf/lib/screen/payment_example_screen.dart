import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../constants/app_colors.dart';

class PaymentExampleScreen extends StatefulWidget {
  @override
  _PaymentExampleScreenState createState() => _PaymentExampleScreenState();
}

class _PaymentExampleScreenState extends State<PaymentExampleScreen> {
  bool isLoading = false;
  String? lastPaymentStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment Examples'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Test Payment Methods',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different payment methods to test the integration',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32),

            // Payment Options
            Expanded(
              child: ListView(
                children: [
                  _buildPaymentOption(
                    'UPI Payment',
                    'Pay using UPI (Google Pay, PhonePe, etc.)',
                    Icons.account_balance_wallet,
                    AppColors.primary,
                    () => _startPayment(PaymentMethod.upi),
                  ),
                  SizedBox(height: 16),
                  _buildPaymentOption(
                    'Card Payment',
                    'Pay using Credit/Debit cards',
                    Icons.credit_card,
                    AppColors.secondary,
                    () => _startPayment(PaymentMethod.card),
                  ),
                  SizedBox(height: 16),
                  _buildPaymentOption(
                    'Net Banking',
                    'Pay using Net Banking',
                    Icons.account_balance,
                    AppColors.premium,
                    () => _startPayment(PaymentMethod.netbanking),
                  ),
                  SizedBox(height: 16),
                  _buildPaymentOption(
                    'Digital Wallet',
                    'Pay using Digital Wallets',
                    Icons.account_balance_wallet,
                    AppColors.referral,
                    () => _startPayment(PaymentMethod.wallet),
                  ),
                ],
              ),
            ),

            // Payment Status
            if (lastPaymentStatus != null) ...[
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lastPaymentStatus!.contains('success')
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: lastPaymentStatus!.contains('success')
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      lastPaymentStatus!.contains('success')
                          ? Icons.check_circle
                          : Icons.error,
                      color: lastPaymentStatus!.contains('success')
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lastPaymentStatus!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: lastPaymentStatus!.contains('success')
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Test Information
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryShade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Use test UPI IDs: success@razorpay, failure@razorpay\n'
                    '• Test cards: 4111 1111 1111 1111\n'
                    '• Amount: ₹1 (test payment)\n'
                    '• No real money will be charged',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildPaymentOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
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

  Future<void> _startPayment(PaymentMethod method) async {
    setState(() {
      isLoading = true;
      lastPaymentStatus = null;
    });

    try {
      final result = await PaymentService.startPayment(
        context: context,
        amount: 1, // ₹1 for testing
        subscriptionType: 'TEST',
        preferredMethod: method,
      );

      setState(() {
        lastPaymentStatus = result.success
            ? 'Payment successful! Payment ID: ${result.paymentId}'
            : 'Payment failed: ${result.message}';
      });
    } catch (e) {
      setState(() {
        lastPaymentStatus = 'Payment error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
} 