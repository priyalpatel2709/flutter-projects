import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ReferralService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate a unique referral code
  static String generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';

    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }

    return code;
  }

  // Create or get user's referral code
  static Future<String> getUserReferralCode() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['referralCode'] != null) {
          return data['referralCode'];
        }
      }

      // Generate new referral code
      String referralCode;
      bool isUnique = false;

      do {
        referralCode = generateReferralCode();
        final existingCode = await _firestore
            .collection('users')
            .where('referralCode', isEqualTo: referralCode)
            .get();
        isUnique = existingCode.docs.isEmpty;
      } while (!isUnique);

      // Save referral code to user document
      await _firestore.collection('users').doc(user.uid).update({
        'referralCode': referralCode,
        'referralCount': 0,
        'referralRewards': 0,
      });

      return referralCode;
    } catch (e) {
      throw Exception('Failed to generate referral code: $e');
    }
  }

  // Validate referral code
  static Future<bool> isValidReferralCode(String code) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get referrer user ID from referral code
  static Future<String?> getReferrerUserId(String code) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Apply referral code during signup
  static Future<void> applyReferralCode(
    String referralCode,
    String newUserId,
  ) async {
    try {
      final referrerUserId = await getReferrerUserId(referralCode);
      if (referrerUserId == null) {
        throw Exception('Invalid referral code');
      }

      // Update new user's document with referrer info
      await _firestore.collection('users').doc(newUserId).update({
        'referredBy': referrerUserId,
        'referredByCode': referralCode,
        'referredAt': FieldValue.serverTimestamp(),
      });

      // Update referrer's stats
      await _firestore.collection('users').doc(referrerUserId).update({
        'referralCount': FieldValue.increment(1),
        'referralRewards': FieldValue.increment(1), // Give 1 reward point
      });

      // Create referral record
      await _firestore.collection('referrals').add({
        'referrerId': referrerUserId,
        'referredUserId': newUserId,
        'referralCode': referralCode,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
        'rewardGiven': true,
      });
    } catch (e) {
      throw Exception('Failed to apply referral code: $e');
    }
  }

  // Get user's referral statistics
  static Future<Map<String, dynamic>> getUserReferralStats() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'referralCode': data['referralCode'] ?? '',
          'referralCount': data['referralCount'] ?? 0,
          'referralRewards': data['referralRewards'] ?? 0,
          'referredBy': data['referredBy'] ?? null,
          'referredByCode': data['referredByCode'] ?? null,
        };
      }

      return {
        'referralCode': '',
        'referralCount': 0,
        'referralRewards': 0,
        'referredBy': null,
        'referredByCode': null,
      };
    } catch (e) {
      throw Exception('Failed to get referral stats: $e');
    }
  }

  // Get list of users referred by current user
  static Future<List<Map<String, dynamic>>> getReferredUsers() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final referrals = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: user.uid)
          // .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> referredUsers = [];

      for (var doc in referrals.docs) {
        final referralData = doc.data();
        final referredUserDoc = await _firestore
            .collection('users')
            .doc(referralData['referredUserId'])
            .get();

        if (referredUserDoc.exists) {
          final userData = referredUserDoc.data() as Map<String, dynamic>;
          referredUsers.add({
            'userId': referredUserDoc.id,
            'name': userData['name'] ?? 'Unknown User',
            'email': userData['email'] ?? '',
            'referredAt': referralData['createdAt'],
            'status': referralData['status'],
          });
        }
      }

      return referredUsers;
    } catch (e) {
      throw Exception('Failed to get referred users: $e');
    }
  }

  // Redeem referral rewards
  static Future<void> redeemReferralRewards(int amount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final currentRewards = data['referralRewards'] ?? 0;

        if (currentRewards < amount) {
          throw Exception('Insufficient referral rewards');
        }

        await _firestore.collection('users').doc(user.uid).update({
          'referralRewards': FieldValue.increment(-amount),
        });

        // Create redemption record
        await _firestore.collection('rewardRedemptions').add({
          'userId': user.uid,
          'amount': amount,
          'redeemedAt': FieldValue.serverTimestamp(),
          'type': 'referral_reward',
        });
      }
    } catch (e) {
      throw Exception('Failed to redeem rewards: $e');
    }
  }

  // Share referral code (simulate sharing)
  static Future<void> shareReferralCode(String code) async {
    // This would integrate with platform sharing
    // For now, we'll just log it
    if (kDebugMode) {
      print('Sharing referral code: $code');
    }
  }
}
