// ignore_for_file: prefer_const_constructors,

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_colors.dart';
import '../models/module.dart';
import '../constants/ad_unit.dart';

class SelectionScreen extends StatefulWidget {
  // final String medium;
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  List<Module> modules = [];
  bool isLoading = true;
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  bool _isTopBannerAdLoaded = false;
  bool _isBottomBannerAdLoaded = false;
  Map<String, dynamic>? userProfile;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadModulesFromDatabase();
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _loadUserProfile();
  }

  void _loadTopBannerAd() {
    _topBannerAd = BannerAd(
      adUnitId: AdUnit.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isTopBannerAdLoaded = true;
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
            _isBottomBannerAdLoaded = true;
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
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadModulesFromDatabase() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });

      // Firestore query
      final querySnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .where('medium', isEqualTo: 'Gujarati')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      final loadedModules = querySnapshot.docs
          .map((doc) => Module.fromFirestore(doc))
          .toList();

      if (!mounted) return;
      setState(() {
        modules = loadedModules;
        isLoading = false;
      });
    } catch (e) {
      log('Error loading modules: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          setState(() {
            userProfile = doc.data() as Map<String, dynamic>;
            isLoadingProfile = false;
          });
        } else {
          setState(() {
            isLoadingProfile = false;
          });
        }
      } catch (e) {
        log('message: Error loading profile: $e');
        if (mounted) {
          setState(() {
            isLoadingProfile = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingProfile = false;
        });
      }
    }
  }

  void _onReferEarnPressed() {
    // TODO: Implement refer and earn functionality
    // You can navigate to a refer screen or show a dialog
    Navigator.pushNamed(context, '/referrals');
    // Or show a dialog
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Refer & Earn'),
    //     content: Text('Share the app with friends and earn rewards!'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _onSubscribePressed() {
    // TODO: Implement subscription functionality
    // You can navigate to a subscription screen
    Navigator.pushNamed(context, '/profile');
    // Or show a dialog
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Subscribe'),
    //     content: Text('Get premium access to all content!'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('Cancel'),
    //       ),
    //       ElevatedButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('Subscribe'),
    //       ),
    //     ],
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Module'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadModulesFromDatabase();
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false), // Cancel
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), // Confirm
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
                  });
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Subtitle
                  if (_isTopBannerAdLoaded)
                    SizedBox(
                      height: _topBannerAd!.size.height.toDouble(),
                      width: _topBannerAd!.size.width.toDouble(),
                      child: AdWidget(ad: _topBannerAd!),
                    ),
                  SizedBox(height: 24),
                  Text(
                    'Available Modules',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose the type of content you want to access',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : modules.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: AppColors.grey400,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No modules available',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No files found.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: modules.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              try {
                                final module = modules[index];
                                return _buildOptionCard(
                                  context: context,
                                  title: module.name,
                                  subtitle: module.description,
                                  icon: _getModuleIcon(module.icon),
                                  route: '/driveFiles',
                                );
                              } catch (e) {
                                return ListTile(
                                  title: Text('Error loading module'),
                                  subtitle: Text('$e'),
                                );
                              }
                            },
                          ),
                  ),
                  // Bottom Buttons Section
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          // Refer & Earn Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onReferEarnPressed,
                              icon: Icon(
                                Icons.share,
                                size: 20,
                                color: AppColors.white,
                              ),
                              label: Text(
                                'Refer & Earn',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Subscribe Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onSubscribePressed,
                              icon: Icon(
                                Icons.star,
                                size: 20,
                                color: AppColors.white,
                              ),
                              label: Text(
                                'Subscribe',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isBottomBannerAdLoaded)
                    SizedBox(
                      height: _bottomBannerAd!.size.height.toDouble(),
                      width: _bottomBannerAd!.size.width.toDouble(),
                      child: AdWidget(ad: _bottomBannerAd!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String iconName) {
    switch (iconName) {
      case 'question_answer_outlined':
        return Icons.question_answer_outlined;
      case 'home_work_outlined':
        return Icons.home_work_outlined;
      case 'quiz_sharp':
        return Icons.quiz_sharp;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.folder;
    }
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    // required Color iconColor,
    // required Color backgroundColor,
    required String route,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          if (title == 'Last Year Paper With Solution') {
            Navigator.pushNamed(
              context,
              '/year-selection',
              arguments: {'medium': 'Gujarati', 'module': title},
            );
            return;
          }
          if (userProfile?['adFree1'] == true) {
            Navigator.pushNamed(
              context,
              route,
              arguments: {'medium': 'Gujarati', 'module': title},
            );
            return;
          }
          Navigator.pushNamed(
            context,
            route,
            arguments: {'medium': 'Gujarati', 'module': title},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.cardGradient,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32, color: AppColors.primary),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
