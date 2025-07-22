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
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModulesFromDatabase();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdUnit.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdUnit.rewardedAdUnitId, // Use test ad unit for development
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _rewardedAd = null;
            _isRewardedAdLoaded = false;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadModulesFromDatabase() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Query modules from the modules collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .where('medium', isEqualTo: 'Gujarati')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      List<Module> loadedModules = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        loadedModules.add(Module.fromFirestore(doc));
      }

      setState(() {
        modules = loadedModules;
        isLoading = false;
      });
    } catch (e) {
      log('message: Error loading modules: $e');
      setState(() {
        isLoading = false;
        modules = [];
      });
    }
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
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: AppColors.surface,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColors.shadowLight,
            //         blurRadius: 8,
            //         offset: Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Container(
            //             padding: EdgeInsets.all(8),
            //             decoration: BoxDecoration(
            //               color: AppColors.primary.withOpacity(0.1),
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             child: Icon(
            //               Icons.folder,
            //               color: AppColors.primary,
            //               size: 20,
            //             ),
            //           ),
            //           // SizedBox(width: 12),
            //           // Expanded(
            //           //   child: Column(
            //           //     crossAxisAlignment: CrossAxisAlignment.start,
            //           //     children: [
            //           //       Text(
            //           //         widget.medium,
            //           //         style: theme.textTheme.headlineSmall?.copyWith(
            //           //           color: AppColors.textPrimary,
            //           //           fontWeight: FontWeight.bold,
            //           //         ),
            //           //       ),
            //           //       Text(
            //           //         'Select a module to continue',
            //           //         style: theme.textTheme.bodyMedium?.copyWith(
            //           //           color: AppColors.textSecondary,
            //           //         ),
            //           //       ),
            //           //     ],
            //           //   ),
            //           // ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // Title and Subtitle
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
                            style: theme.textTheme.headlineSmall?.copyWith(
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
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return _buildOptionCard(
                          context: context,
                          title: module.name,
                          subtitle: module.description,
                          icon: _getModuleIcon(module.icon),
                          // iconColor: _getModuleColor(module.color),
                          // backgroundColor: _getModuleBackgroundColor(module.backgroundColor),
                          route: '/driveFiles',
                        );
                      },
                    ),
            ),
            if (_isBannerAdLoaded)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
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

  Color _getModuleColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'success':
        return AppColors.success;
      case 'premium':
        return AppColors.premium;
      default:
        return AppColors.primary;
    }
  }

  Color _getModuleBackgroundColor(String backgroundColorName) {
    switch (backgroundColorName) {
      case 'primaryShade50':
        return AppColors.primaryShade50;
      case 'premiumLight':
        return AppColors.premiumLight;
      case 'successLight':
        return AppColors.success.withOpacity(0.1);
      default:
        return AppColors.primaryShade50;
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
        // onTap: () {
        //   Navigator.pushNamed(
        //     context,
        //     route,
        //     arguments: {'medium': 'Gujarati', 'module': title},
        //   );
        // },
        onTap: () async {
          if (_isRewardedAdLoaded && _rewardedAd != null) {
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _loadRewardedAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _loadRewardedAd();
              },
            );
            _rewardedAd!.show(
              onUserEarnedReward: (ad, reward) {
                Navigator.pushNamed(
                  context,
                  route,
                  arguments: {'medium': 'Gujarati', 'module': title},
                );
              },
            );
            setState(() {
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad not loaded yet, please try again.')),
            );
            _loadRewardedAd();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.cardGradient,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Text(
                //   subtitle,
                //   textAlign: TextAlign.center,
                //   style: theme.textTheme.bodySmall?.copyWith(
                //     color: AppColors.textSecondary,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
