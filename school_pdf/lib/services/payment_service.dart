import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/razorpay_config.dart';

// Payment status enum
enum PaymentStatus { pending, success, failed, cancelled }

// Payment method enum
enum PaymentMethod { upi, card, netbanking, wallet, other }

class PaymentService {
  static final Razorpay _razorpay = Razorpay();
  static bool _isInitialized = false;

  // Initialize Razorpay
  static void initialize() {
    if (_isInitialized) return;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;
    log('Razorpay initialized successfully');
  }

  // Dispose Razorpay
  static void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
      log('Razorpay disposed');
    }
  }

  // Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Payment success: ${response.paymentId}');
    _savePaymentRecord(
      response.paymentId!,
      response.orderId!,
      PaymentStatus.success,
      response.data,
    );
  }

  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment failed: ${response.message}');
    _savePaymentRecord(null, null, PaymentStatus.failed, response.message);
  }

  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    log('External wallet: ${response.walletName}');
  }

  // Create order on server
  static Future<String?> _createOrder({
    required int amount,
    required String currency,
    required String receipt,
  }) async {
    try {
      final url = Uri.parse('${RazorpayConfig.baseUrl}/orders');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}'))}',
      };

      final body = jsonEncode({
        'amount': amount * 100, // Convert to paise //make changes
        'currency': currency,
        'receipt': receipt,
        'notes': {'description': 'Subscription payment'},
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        log('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating order: $e');
      return null;
    }
  }

  // Save payment record to Firestore
  static Future<void> _savePaymentRecord(
    String? paymentId,
    String? orderId,
    PaymentStatus status,
    dynamic data,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.uid,
        'paymentId': paymentId,
        'orderId': orderId,
        'status': status.name,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error saving payment record: $e');
    }
  }

  // Start payment process
  static Future<PaymentResult> startPayment({
    required BuildContext context,
    required int amount,
    required String subscriptionType,
    String currency = 'INR',
    PaymentMethod preferredMethod = PaymentMethod.upi,
  }) async {
    if (!_isInitialized) {
      initialize();
    }

    try {
      // Create order
      final orderId = await _createOrder(
        amount: amount,
        currency: currency,
        receipt: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (orderId == null) {
        return PaymentResult(
          success: false,
          message: 'Failed to create payment order',
        );
      }

      // Prepare payment options
      final options = {
        'key': RazorpayConfig.keyId,
        'amount': amount * 100, // Convert to paise
        'currency': currency,
        'name': RazorpayConfig.appName,
        'description': '$subscriptionType Subscription',
        'order_id': orderId,
        'prefill': {
          'contact': '',
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
          'name': FirebaseAuth.instance.currentUser?.displayName ?? '',
        },
        'theme': {
          'color': '#${AppColors.primary.value.toRadixString(16).substring(2)}',
        },
        'method': {
          'upi': {'flow': 'intent', 'vpa': ''},
          'card': {},
          'netbanking': {},
          'wallet': {},
        },
        'config': {
          'display': {
            'blocks': {
              'banks': {
                'name': 'Pay using UPI',
                'instruments': [
                  {'method': 'upi'},
                ],
              },
              'cards': {
                'name': 'Pay using Cards',
                'instruments': [
                  {'method': 'card'},
                ],
              },
              'wallets': {
                'name': 'Pay using Wallets',
                'instruments': [
                  {'method': 'wallet'},
                ],
              },
            },
            'sequence': ['block.banks', 'block.cards', 'block.wallets'],
            'prefill': {'method': preferredMethod.name},
          },
        },
      };

      // Show payment dialog
      final result = await _showPaymentDialog(
        context: context,
        options: options,
        amount: amount,
        subscriptionType: subscriptionType,
      );

      return result;
    } catch (e) {
      log('Payment error: $e');
      return PaymentResult(success: false, message: 'Payment failed: $e');
    }
  }

  // Show payment dialog
  static Future<PaymentResult> _showPaymentDialog({
    required BuildContext context,
    required Map<String, dynamic> options,
    required int amount,
    required String subscriptionType,
  }) async {
    final completer = Completer<PaymentResult>();

    // Show payment dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        options: options,
        amount: amount,
        subscriptionType: subscriptionType,
        onResult: (result) {
          completer.complete(result);
        },
      ),
    );

    return completer.future;
  }

  // Get payment history
  static Future<List<PaymentRecord>> getPaymentHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PaymentRecord(
          id: doc.id,
          paymentId: data['paymentId'],
          orderId: data['orderId'],
          status: PaymentStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => PaymentStatus.pending,
          ),
          amount: data['amount'] ?? 0,
          timestamp: data['timestamp']?.toDate(),
        );
      }).toList();
    } catch (e) {
      log('Error getting payment history: $e');
      return [];
    }
  }

  // Verify payment on server
  static Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final url = Uri.parse('${RazorpayConfig.baseUrl}/payments/$paymentId');
      final headers = {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}'))}',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'captured';
      }
      return false;
    } catch (e) {
      log('Error verifying payment: $e');
      return false;
    }
  }
}

// Payment result class
class PaymentResult {
  final bool success;
  final String? message;
  final String? paymentId;
  final String? orderId;

  PaymentResult({
    required this.success,
    this.message,
    this.paymentId,
    this.orderId,
  });
}

// Payment record class
class PaymentRecord {
  final String id;
  final String? paymentId;
  final String? orderId;
  final PaymentStatus status;
  final int amount;
  final DateTime? timestamp;

  PaymentRecord({
    required this.id,
    this.paymentId,
    this.orderId,
    required this.status,
    required this.amount,
    this.timestamp,
  });
}

// Payment dialog widget
class PaymentDialog extends StatefulWidget {
  final Map<String, dynamic> options;
  final int amount;
  final String subscriptionType;
  final Function(PaymentResult) onResult;

  const PaymentDialog({
    Key? key,
    required this.options,
    required this.amount,
    required this.subscriptionType,
    required this.onResult,
  }) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool isProcessing = false;
  bool isSuccess = false;
  bool isFailed = false;
  String currentStep = 'initial';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  Future<void> _startPayment() async {
    setState(() {
      isProcessing = true;
      currentStep = 'initializing';
    });

    try {
      // Initialize Razorpay
      PaymentService.initialize();

      // Start payment
      final razorpay = Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        setState(() {
          isProcessing = false;
          isSuccess = true;
          currentStep = 'success';
        });

        widget.onResult(
          PaymentResult(
            success: true,
            paymentId: response.paymentId,
            orderId: response.orderId,
          ),
        );

        Navigator.of(context).pop();
      });

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        setState(() {
          isProcessing = false;
          isFailed = true;
          currentStep = 'failed';
          errorMessage = response.message;
        });

        widget.onResult(
          PaymentResult(success: false, message: response.message),
        );
      });

      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
        log('External wallet: ${response.walletName}');
      });

      // Open payment
      razorpay.open(widget.options);
    } catch (e) {
      setState(() {
        isProcessing = false;
        isFailed = true;
        currentStep = 'failed';
        errorMessage = e.toString();
      });

      widget.onResult(PaymentResult(success: false, message: e.toString()));
    }
  }

  String _getStepMessage() {
    switch (currentStep) {
      case 'initializing':
        return 'Initializing payment...';
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
      case 'initializing':
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
      case 'initializing':
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
                  'Payment Gateway',
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
                    '₹${widget.amount}',
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
                  if (errorMessage != null) ...[
                    SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onResult(PaymentResult(success: false));
                      },
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
                          errorMessage = null;
                        });
                        _startPayment();
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onResult(PaymentResult(success: isSuccess));
                  },
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
