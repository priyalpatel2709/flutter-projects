import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saf/saf.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/ad_unit.dart';
import '../constants/app_colors.dart';

class UsersTab extends StatefulWidget {
  final ThemeData theme;
  const UsersTab({super.key, required this.theme});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<QueryDocumentSnapshot> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _allUsers = snapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Users',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                // onPressed: _downloadPromodoesCsv,
                onPressed: () => _downloadUsersExcel(context),
                icon: Icon(Icons.download),
                label: Text('Download CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or promo code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUsersExcel(BuildContext context) async {
    try {


      // Step 2: Fetch Firestore users
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final users = snapshot.docs.map((doc) => doc.data()).toList();

      if (users.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No users found')));
        return;
      }

      // Step 3: Create Excel workbook
      var excel = Excel.createExcel();

      // Remove default sheet and create new one
      excel.delete('Sheet1');
      var sheet = excel['Users'];

      // Step 4: Define headers
      final headers = [
        'Name',
        'Email',
        'Phone Number',
        'Subscription',
        'Subscription Price',
        'Referral Code',
        'Referral Count',
        'Referral Rewards',
        'Promo Code',
        'Referred By (Email)',
        'Referred At',
        'Joined (Created At)',
        'Is Admin',
      ];

      // Insert header row
      for (var i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(
          headers[i],
        );
      }

      // Step 5: Populate rows
      int rowIndex = 1; // Start from row 1 (row 0 is headers)
      for (var doc in snapshot.docs) {
        final data = doc.data();

        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate().toString()
            : '';

        final referredAt = data['referredAt'] is Timestamp
            ? (data['referredAt'] as Timestamp).toDate().toString()
            : '';

        String referredBy = '';
        if (data['referredBy'] != null) {
          final referredUser = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['referredBy'])
              .get();
          referredBy = referredUser.data()?['email'] ?? '';
        }

        final rowData = [
          data['name'] ?? '',
          data['email'] ?? '',
          data['phoneNumber'] ?? '',
          data['subscription'] ?? '',
          data['subscriptionPrice']?.toString() ?? '',
          data['referralCode'] ?? '',
          data['referralCount']?.toString() ?? '0',
          data['referralRewards']?.toString() ?? '0',
          data['promoCode'] ?? '',
          referredBy,
          referredAt,
          createdAt,
          (data['isAdmin'] ?? false) ? 'Yes' : 'No',
        ];

        // Insert data row
        for (var i = 0; i < rowData.length; i++) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
              )
              .value = TextCellValue(
            rowData[i],
          );
        }

        rowIndex++;
      }

      // Step 6: Encode Excel file to bytes
      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Failed to encode Excel file');
      }

      // Step 7: Save to Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String fileName = 'users_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excelBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ File saved to Downloads/$fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildUserList() {
    final filteredUsers = _allUsers.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final promoCode = (data['promoCode'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          promoCode.contains(_searchQuery);
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(child: Text('No matching users found.'));
    }

    return ListView.separated(
      itemCount: filteredUsers.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final user = filteredUsers[index].data() as Map<String, dynamic>;
        final createdAt = user['createdAt'] as Timestamp?;
        final isAdmin = user['isAdmin'] as bool? ?? false;
        final referralCount = user['referralCount'] ?? 0;
        final referralRewards = user['referralRewards'] ?? 0;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isAdmin ? AppColors.premium : AppColors.primary,
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user['name'] ?? 'No Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isAdmin)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.premium,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? 'No Email'),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSubscriptionColor(user['subscription']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (user['subscription']?.toString() ??
                                AdUnit.freeSubscriptionType)
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user['subscriptionPrice'] != null)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          '₹${user['subscriptionPrice']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.phone,
                      'Phone',
                      user['phoneNumber']?.toString() ?? 'Not provided',
                    ),
                    _buildDetailRow(
                      Icons.code,
                      'Referral Code',
                      user['referralCode']?.toString() ?? 'Not available',
                    ),
                    _buildDetailRow(
                      Icons.group,
                      'Referrals',
                      '$referralCount users',
                    ),
                    _buildDetailRow(
                      Icons.card_giftcard,
                      'Rewards',
                      '$referralRewards earned',
                    ),
                    if (user['referredBy'] != null)
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserByIid(user['referredBy']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildDetailRow(
                              Icons.person_add,
                              'Referred By',
                              'Loading...',
                            );
                          } else if (snapshot.hasError) {
                            return _buildDetailRow(
                              Icons.person_add,
                              'Referred By',
                              'Error',
                            );
                          } else {
                            final referredUser = snapshot.data ?? {};
                            final referredName =
                                referredUser['email'] ?? 'Unknown';
                            return _buildDetailRow(
                              Icons.person_add,
                              'Referred By',
                              referredName,
                            );
                          }
                        },
                      ),
                    if (user['referredAt'] != null)
                      _buildDetailRow(
                        Icons.schedule,
                        'Referred At',
                        _formatTimestamp(user['referredAt'] as Timestamp),
                      ),
                    if (user['promoCode'] != null)
                      _buildDetailRow(
                        Icons.code,
                        'Promo Code',
                        user['promoCode'].toString(),
                      ),
                    if (createdAt != null)
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Joined',
                        _formatTimestamp(createdAt),
                      ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => showReferralDialog(context, user),
                          icon: Icon(Icons.share, size: 16),
                          label: Text('View Referrals'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(String? subscription) {
    switch (subscription?.toUpperCase()) {
      case 'PREMIUM':
        return AppColors.premium;
      case 'BASIC':
        return Colors.orange;
      case 'FREE':
      default:
        return AppColors.grey600;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<Map<String, dynamic>> _getUserByIid(String userUid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .get();
    return userDoc.data() ?? {};
  }

  Future<List<Map<String, dynamic>>> _fetchReferralDetails(
    List<dynamic> referralList,
  ) async {
    List<Map<String, dynamic>> result = [];

    for (var item in referralList) {
      final uid = item['userId'];
      final isRewarded = item['isRewarded'] ?? false;

      final data = await _getUserByIid(uid);

      result.add({
        'uid': uid,
        'name': data['name'],
        'email': data['email'],
        'isRewarded': isRewarded,
      });
    }

    return result;
  }

  Future<void> showReferralDialog(
    BuildContext context,
    Map<String, dynamic> user,
  ) async {
    final referralList = user['referralUserList'] ?? [];
    final currentUserId = user['email'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReferralDetails(referralList),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            final referrals = snapshot.data!;

            if (referrals.isEmpty) {
              return Text('No referrals found.');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: referrals.map((refUser) {
                final isRewarded = refUser['isRewarded'] == true;
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(refUser['name'] ?? 'Unknown'),
                  subtitle: Text(refUser['email'] ?? ''),
                  trailing: isRewarded
                      ? const Text(
                          'Rewarded',
                          style: TextStyle(color: Colors.green),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            await _rewardUser(
                              currentUserEmail: currentUserId,
                              referralUserId: refUser['uid'],
                            );
                            Navigator.pop(context);
                            await _loadUsers(); // Refresh user list
                          },
                          child: const Text('Reward'),
                        ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _rewardUser({
    required String currentUserEmail,
    required String referralUserId,
  }) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUserEmail)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final userDoc = query.docs.first;
    final userRef = userDoc.reference;
    final userData = userDoc.data();

    List<dynamic> referralList = userData['referralUserList'] ?? [];

    final updatedList = referralList.map((entry) {
      if (entry['userId'] == referralUserId) {
        return {'userId': referralUserId, 'isRewarded': true};
      }
      return entry;
    }).toList();

    final updatedRewardCount = (userData['referralRewards'] ?? 0) - 1;

    await userRef.update({
      'referralUserList': updatedList,
      'referralRewards': updatedRewardCount < 0 ? 0 : updatedRewardCount,
    });
  }
}
