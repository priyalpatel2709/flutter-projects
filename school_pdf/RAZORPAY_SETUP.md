# Razorpay Payment Gateway Setup

This guide will help you set up Razorpay payment gateway with UPI support for your Flutter app.

## Prerequisites

1. A Razorpay account (sign up at https://razorpay.com)
2. Flutter development environment
3. Android/iOS development setup

## Step 1: Create Razorpay Account

1. Go to https://razorpay.com and sign up for an account
2. Complete the KYC process
3. Access your Razorpay Dashboard

## Step 2: Get API Keys

### Test Environment
1. In your Razorpay Dashboard, go to Settings > API Keys
2. Generate a new key pair for test environment
3. Copy the Key ID and Key Secret

### Production Environment
1. Once your app is ready for production, generate live API keys
2. Keep your live keys secure and never commit them to version control

## Step 3: Update Configuration

1. Open `lib/constants/razorpay_config.dart`
2. Replace the placeholder values with your actual API keys:


## Step 4: Android Setup

### Add Internet Permission
Add the following permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Update Minimum SDK Version
Ensure your `android/app/build.gradle.kts` has:
```kotlin
minSdk = 23
```

## Step 5: iOS Setup

### Add URL Schemes
Add the following to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>razorpay</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>razorpay</string>
        </array>
    </dict>
</array>
```

## Step 6: Test the Integration

1. Run your app in test mode
2. Try making a test payment using UPI
3. Use test UPI IDs like:
   - `success@razorpay` (for successful payment)
   - `failure@razorpay` (for failed payment)

## Step 7: Payment Methods Supported

The integration supports the following payment methods:

### UPI (Unified Payments Interface)
- Google Pay
- PhonePe
- Paytm
- BHIM
- All UPI-enabled apps

### Cards
- Credit Cards
- Debit Cards
- International Cards

### Net Banking
- All major Indian banks

### Digital Wallets
- Paytm Wallet
- Amazon Pay
- FreeCharge
- Mobikwik

## Step 8: Production Deployment

1. Set `isProduction = true` in `RazorpayConfig`
2. Use live API keys
3. Test thoroughly with small amounts
4. Monitor transactions in Razorpay Dashboard

## Step 9: Security Best Practices

1. **Never expose API keys in client-side code** (for production)
2. **Use server-side order creation** for production
3. **Verify payment signatures** on your server
4. **Implement webhook handling** for payment status updates
5. **Use HTTPS** for all API calls

## Step 10: Server-Side Integration (Recommended for Production)

For production apps, it's recommended to create orders on your server:

```dart
// Client-side: Request order from your server
Future<String?> createOrderFromServer({
  required int amount,
  required String currency,
  required String receipt,
}) async {
  final response = await http.post(
    Uri.parse('https://your-server.com/api/create-order'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'amount': amount,
      'currency': currency,
      'receipt': receipt,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['order_id'];
  }
  return null;
}
```

## Troubleshooting

### Common Issues

1. **Payment fails with "Invalid key"**
   - Check if you're using the correct API keys
   - Ensure the keys match your environment (test/live)

2. **UPI payment not working**
   - Verify UPI app is installed on device
   - Check if UPI ID is valid
   - Ensure proper internet connectivity

3. **App crashes on payment**
   - Check Android/iOS setup
   - Verify all permissions are added
   - Check console logs for specific errors

### Debug Mode

Enable debug logging by adding this to your payment service:

```dart
static void initialize() {
  if (_isInitialized) return;

  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  // Enable debug logging
  if (kDebugMode) {
    print('Razorpay initialized in debug mode');
  }

  _isInitialized = true;
}
```

## Support

- Razorpay Documentation: https://razorpay.com/docs/
- Flutter Razorpay Plugin: https://pub.dev/packages/razorpay_flutter
- Razorpay Support: support@razorpay.com

## License

This integration is provided as-is. Please refer to Razorpay's terms of service for usage guidelines. 