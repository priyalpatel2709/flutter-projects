import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/ad_unit.dart';

class SubscriptionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> buySubscription({
    required String subscriptionType,
    required bool isClaim,
    String? referredBy,
    required int payableAmount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (subscriptionType != AdUnit.freeSubscriptionType && !isClaim) {
      bool paymentSuccess = await _showPaymentSimulation(
        subscriptionType,
        payableAmount,
      );
      if (!paymentSuccess) {
        return; // User cancelled or payment failed
      }
    }

    await _firestore.collection('users').doc(user.uid).update({
      'subscription': subscriptionType,
      'subscriptionExpiry': DateTime.now()
          .add(Duration(days: AdUnit.eligibleCount))
          .toIso8601String(),
    });

    if (subscriptionType != AdUnit.freeSubscriptionType && !isClaim) {
      if (referredBy != null) {
        await _firestore.collection('users').doc(referredBy).update({
          'activeReferredUserList': FieldValue.arrayUnion([user!.uid]),
        });
      }
    }
  }

  static Future<bool> _showPaymentSimulation(
    String subscriptionType,
    int payableAmount,
  ) async {
    log('take payment for $subscriptionType for $payableAmount');
    return true; // Simulate payment success for testing purposes
  }
}
