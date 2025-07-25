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
  Map<String, dynamic>? userProfile;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadModulesFromDatabase();
    _loadBannerAd();
    _loadRewardedAd(); // Preload rewarded ad on screen load
    _loadUserProfile();
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

  // Helper to wait for rewarded ad to load
  Future<void> _waitForRewardedAd() async {
    if (_isRewardedAdLoaded) return;
    while (!_isRewardedAdLoaded) {
      await Future.delayed(Duration(milliseconds: 100));
    }
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
      // log('message: Error loading modules: $e');
      setState(() {
        isLoading = false;
        modules = [];
      });
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
        setState(() {
          isLoadingProfile = false;
        });
      }
    } else {
      setState(() {
        isLoadingProfile = false;
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
                        } catch (e, stack) {
                          log('Error in itemBuilder: $e\n$stack');
                          return ListTile(
                            title: Text('Error loading module'),
                            subtitle: Text('$e'),
                          );
                        }
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
          if (userProfile?['adFree'] == true) {
            Navigator.pushNamed(
              context,
              route,
              arguments: {'medium': 'Gujarati', 'module': title},
            );
            return;
          }
          if (!_isRewardedAdLoaded || _rewardedAd == null) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(child: CircularProgressIndicator()),
            );
            // Wait for ad to load
            await _waitForRewardedAd();
            Navigator.of(context, rootNavigator: true).pop(); // Dismiss dialog
          }
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
          }
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
