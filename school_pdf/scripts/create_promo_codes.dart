import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // Sample promo codes
  final promoCodes = [
    {
      'code': 'WELCOME20',
      'discountPercentage': 20,
      'isActive': true,
      'description': 'Welcome discount - 20% off',
      'validUntil': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      'maxUses': 100,
      'currentUses': 0,
    },
    {
      'code': 'SAVE30',
      'discountPercentage': 30,
      'isActive': true,
      'description': 'Special offer - 30% off',
      'validUntil': DateTime.now().add(Duration(days: 60)).toIso8601String(),
      'maxUses': 50,
      'currentUses': 0,
    },
    {
      'code': 'FLASH50',
      'discountPercentage': 50,
      'isActive': true,
      'description': 'Flash sale - 50% off',
      'validUntil': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      'maxUses': 25,
      'currentUses': 0,
    },
  ];

  try {
    for (final promoCode in promoCodes) {
      await firestore.collection('promoCodes').add(promoCode);
      print('Added promo code: ${promoCode['code']}');
    }
    print('All promo codes added successfully!');
  } catch (e) {
    print('Error adding promo codes: $e');
  }
} 