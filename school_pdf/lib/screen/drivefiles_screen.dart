import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/ad_unit.dart';

class DriveFilesScreen extends StatefulWidget {
  final String title;
  final String medium;
  final String module;

  const DriveFilesScreen({
    super.key,
    required this.title,
    required this.medium,
    required this.module,
  });

  @override
  State<DriveFilesScreen> createState() => _DriveFilesScreenState();
}

class _DriveFilesScreenState extends State<DriveFilesScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  List<DriveFile> files = [];
  bool isLoadingFiles = true;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFilesFromDatabase();
    _loadBannerAd();
    _loadRewardedAd();
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
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFilesFromDatabase() async {
    try {
      setState(() {
        isLoadingFiles = true;
      });

      // Query files from Firestore based on medium and module
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where('medium', isEqualTo: widget.medium)
          .where('module', isEqualTo: widget.module)
          .get();

      List<DriveFile> loadedFiles = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        loadedFiles.add(
          DriveFile(
            name: data['name'] ?? '',
            id: data['fileId'] ?? '',
            type: data['type'] ?? 'pdf',
            isFree: data['isFree'] ?? true,
          ),
        );
      }

      setState(() {
        files = loadedFiles;
        isLoadingFiles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingFiles = false;
        files = [];
      });
    }
  }

  // Check if user has premium subscription
  bool get _hasPremiumSubscription {
    final subscription = userProfile?['subscription'];
    return subscription == AdUnit.premiumSubscriptionType || subscription == 'pro';
  }

  // Check if subscription is expired
  bool get _isSubscriptionExpired {
    final expiryDate = userProfile?['subscriptionExpiry'];
    if (expiryDate == null) return true;

    try {
      final expiry = DateTime.parse(expiryDate);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  // Check if user can access paid content
  bool _canAccessPaidContent() {
    return _hasPremiumSubscription && !_isSubscriptionExpired;
  }

  // Get the files loaded from database
  List<DriveFile> get _files => files;

  void _handleFileTap(DriveFile file) {
    if (!file.isFree && !_canAccessPaidContent()) {
      _showSubscriptionDialog();
    } else {
      if (userProfile?['adFree'] == true) {
        _openDriveFile(file.id);
      } else {
        _showAdAndOpenFile(file);
      }
    }
  }

  Future<void> _showAdAndOpenFile(DriveFile file) async {
    if (userProfile?['adFree'] == true) {
      _openDriveFile(file.id);
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
          _openDriveFile(file.id);
        },
      );
      setState(() {
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
      });
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.premium),
            SizedBox(width: 8),
            Text('Premium Content', style: TextStyle(color: AppColors.primary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This file requires a premium subscription.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Upgrade to Premium or Pro to access all files.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadFilesFromDatabase();
            },
          ),
        ],
      ),
      body: (isLoading || isLoadingFiles)
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.folder_open,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.module,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${_files.length} files available',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_files.isEmpty)
                    Expanded(
                      child: Center(
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
                              'No files available for this selection',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Medium: ${widget.medium}\nModule: ${widget.module}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final canAccess =
                              file.isFree || _canAccessPaidContent();

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shadowColor: AppColors.shadowLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: _getFileColor(file.type),
                                    child: Icon(
                                      _getFileIcon(file.type),
                                      color: AppColors.white,
                                      size: 24,
                                    ),
                                  ),
                                  if (!file.isFree)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.premium,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.lock,
                                          size: 12,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: canAccess
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                                  if (!file.isFree)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.premium.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.premium.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'PREMIUM',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.premium,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  canAccess
                                      ? 'Tap to open in Google Drive'
                                      : 'Premium subscription required',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: canAccess
                                        ? AppColors.textSecondary
                                        : AppColors.premium,
                                  ),
                                ),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: canAccess
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.premium.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  canAccess ? Icons.open_in_new : Icons.lock,
                                  color: canAccess
                                      ? AppColors.primary
                                      : AppColors.premium,
                                  size: 20,
                                ),
                              ),
                              onTap: () => _handleFileTap(file),
                            ),
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

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.description;
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case 'pdf':
        return AppColors.filePdf;
      case 'spreadsheet':
        return AppColors.fileSpreadsheet;
      case 'presentation':
        return AppColors.filePresentation;
      case 'image':
        return AppColors.fileImage;
      case 'document':
        return AppColors.fileDocument;
      default:
        return AppColors.fileDocument;
    }
  }

  Future<void> _openDriveFile(String fileId) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Opening file...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Try multiple approaches to open the file
      final urls = [
        'https://drive.google.com/file/d/$fileId/view?usp=sharing',
        'https://drive.google.com/open?id=$fileId',
        'https://docs.google.com/document/d/$fileId/edit?usp=sharing',
        'https://docs.google.com/spreadsheets/d/$fileId/edit?usp=sharing',
        'https://docs.google.com/presentation/d/$fileId/edit?usp=sharing',
      ];

      bool success = false;

      for (String url in urls) {
        try {
          final Uri uri = Uri.parse(url);

          await launchUrl(uri, mode: LaunchMode.externalApplication);
          success = true;

          break;
        } catch (e) {
          continue;
        }
      }

      if (!success) {
        // If all external attempts failed, try in-app web view
        final webUrl =
            'https://drive.google.com/file/d/$fileId/view?usp=sharing';
        final webUri = Uri.parse(webUrl);

        await launchUrl(webUri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open file. Please check your internet connection and try again.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

class DriveFile {
  final String name;
  final String id;
  final String type;
  final bool isFree;

  const DriveFile({
    required this.name,
    required this.id,
    required this.type,
    required this.isFree,
  });
}
