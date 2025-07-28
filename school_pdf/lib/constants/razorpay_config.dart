import 'package:flutter_dotenv/flutter_dotenv.dart';

class RazorpayConfig {
  // Test keys - Replace with your actual Razorpay test keys
  static String testKeyId = dotenv.env['testKeyId'] ?? '';
  static String testKeySecret = dotenv.env['testKeySecret'] ?? '';

  // Live keys - Replace with your actual Razorpay live keys for production
  static String liveKeyId = dotenv.env['liveKeyId'] ?? '';
  static String liveKeySecret = dotenv.env['liveKeySecret'] ?? '';

  // Environment flag - Set to true for production
  static const bool isProduction = false;

  // Get current key based on environment
  static String get keyId => isProduction ? liveKeyId : testKeyId;
  static String get keySecret => isProduction ? liveKeySecret : testKeySecret;

  // Base URL for Razorpay API
  static const String baseUrl = 'https://api.razorpay.com/v1';

  // App name for payment gateway
  static const String appName = 'School Friend';

  // Default currency
  static const String defaultCurrency = 'INR';

  // Payment description
  static const String paymentDescription = 'Subscription Payment';
}
