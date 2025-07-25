import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:media_store_plus/media_store_plus.dart';

import '../constants/app_colors.dart';

class AdminAddFileScreen extends StatefulWidget {
  @override
  _AdminAddFileScreenState createState() => _AdminAddFileScreenState();
}

class _AdminAddFileScreenState extends State<AdminAddFileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // File form controllers
  final _fileFormKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();
  final _fileIdController = TextEditingController();
  final _fileDescriptionController = TextEditingController();
  final _fileSizeController = TextEditingController();

  // Module form controllers
  final _moduleFormKey = GlobalKey<FormState>();
  final _moduleNameController = TextEditingController();
  final _moduleDescriptionController = TextEditingController();

  // File form variables
  String _selectedType = 'pdf';
  String _selectedMedium = 'Gujarati';
  String _selectedModule = '';
  bool _isFree = true;
  bool _isFileLoading = false;

  // Module form variables
  String _selectedModuleMedium = 'Gujarati';
  String _selectedModuleIcon = 'folder';
  int _selectedOrder = 1;
  bool _isModuleActive = true;
  bool _isModuleLoading = false;

  final List<String> _fileTypes = [
    'pdf',
    'spreadsheet',
    'presentation',
    'image',
    'document',
  ];
  // final List<String> _mediums = ['Gujarati', 'English'];
  List<String> _modules = [];
  bool _isLoadingModules = false;
  final List<String> _moduleIcons = [
    'folder',
    'question_answer_outlined',
    'home_work_outlined',
    'quiz_sharp',
    'book',
    'school',
    'assignment',
    'description',
    'article',
    'library_books',
  ];

  // Promo Code Tab
  final _promoCodeFormKey = GlobalKey<FormState>();
  final _promoCodeController = TextEditingController();
  final _promoDescriptionController = TextEditingController();
  bool _isPromoLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadModulesForMedium(_selectedMedium);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fileNameController.dispose();
    _fileIdController.dispose();
    _fileDescriptionController.dispose();
    _fileSizeController.dispose();
    _moduleNameController.dispose();
    _moduleDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadModulesForMedium(String medium) async {
    setState(() {
      _isLoadingModules = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .where('medium', isEqualTo: medium)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      List<String> loadedModules = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        loadedModules.add(doc['name'] as String);
      }

      setState(() {
        _modules = loadedModules;
        _selectedModule = loadedModules.isNotEmpty ? loadedModules.first : '';
        _isLoadingModules = false;
      });
    } catch (e) {
      setState(() {
        _modules = [];
        _selectedModule = '';
        _isLoadingModules = false;
      });
    }
  }

  Future<void> _addFile() async {
    if (!_fileFormKey.currentState!.validate()) return;

    if (_modules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No modules available for the selected medium. Please add modules first.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isFileLoading = true;
    });

    try {
      final fileData = {
        'name': _fileNameController.text.trim(),
        'fileId': _fileIdController.text.trim(),
        'type': _selectedType,
        'isFree': _isFree,
        'medium': _selectedMedium,
        'module': _selectedModule,
        'description': _fileDescriptionController.text.trim(),
        'uploadDate': FieldValue.serverTimestamp(),
        'fileSize': _fileSizeController.text.trim(),
        'downloads': 0,
        'tags': [], // You can add tag functionality later
      };

      await FirebaseFirestore.instance.collection('files').add(fileData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form
      _fileFormKey.currentState!.reset();
      _fileNameController.clear();
      _fileIdController.clear();
      _fileDescriptionController.clear();
      _fileSizeController.clear();
      setState(() {
        _selectedType = 'pdf';
        _selectedMedium = 'Gujarati';
        _isFree = true;
      });
      // Reload modules for the current medium
      _loadModulesForMedium(_selectedMedium);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isFileLoading = false;
      });
    }
  }

  Future<void> _addModule() async {
    if (!_moduleFormKey.currentState!.validate()) return;

    setState(() {
      _isModuleLoading = true;
    });

    try {
      final moduleData = {
        'name': _moduleNameController.text.trim(),
        'medium': _selectedModuleMedium,
        'description': _moduleDescriptionController.text.trim(),
        'icon': _selectedModuleIcon,
        'isActive': _isModuleActive,
        'order': _selectedOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('modules').add(moduleData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Module added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form
      _moduleFormKey.currentState!.reset();
      _moduleNameController.clear();
      _moduleDescriptionController.clear();
      setState(() {
        _selectedModuleMedium = 'Gujarati';
        _selectedModuleIcon = 'folder';
        _selectedOrder = 1;
        _isModuleActive = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding module: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isModuleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Add Module'),
            Tab(text: 'Add File'),
            Tab(text: 'Users'),
            Tab(text: 'Add Promo Code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddModuleTab(theme),
          _buildAddFileTab(theme),
          _buildUsersTab(theme),
          _buildAddPromoCodeTab(theme),
        ],
      ),
    );
  }

  Widget _buildAddFileTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _fileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Name
            TextFormField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'File Name *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter file name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Google Drive File ID
            TextFormField(
              controller: _fileIdController,
              decoration: InputDecoration(
                labelText: 'Google Drive File ID *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Get this from the Google Drive URL12',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter file ID';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // File Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'File Type *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _fileTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Medium
            // DropdownButtonFormField<String>(
            //   value: _selectedMedium,
            //   decoration: InputDecoration(
            //     labelText: 'Medium *',
            //     labelStyle: TextStyle(color: AppColors.primary),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   items: _mediums.map((String medium) {
            //     return DropdownMenuItem<String>(
            //       value: medium,
            //       child: Text(medium),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       _selectedMedium = newValue!;
            //     });
            //     _loadModulesForMedium(newValue!);
            //   },
            // ),
            // SizedBox(height: 16),

            // Module
            DropdownButtonFormField<String>(
              value: _selectedModule,
              decoration: InputDecoration(
                labelText: 'Module *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _isLoadingModules
                    ? Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : null,
                helperText: _modules.isEmpty && !_isLoadingModules
                    ? 'No modules available for selected medium. Add modules first.'
                    : null,
              ),
              items: _modules.map((String module) {
                return DropdownMenuItem<String>(
                  value: module,
                  child: Text(module),
                );
              }).toList(),
              onChanged: _modules.isEmpty
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedModule = newValue!;
                      });
                    },
            ),
            SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _fileDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // File Size
            TextFormField(
              controller: _fileSizeController,
              decoration: InputDecoration(
                labelText: 'File Size (e.g., 2.5MB)',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Is Free
            SwitchListTile(
              title: Text('Free File'),
              subtitle: Text('Make this file available for free users'),
              value: _isFree,
              onChanged: (bool value) {
                setState(() {
                  _isFree = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFileLoading ? null : _addFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isFileLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      )
                    : Text(
                        'Add File',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddModuleTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _moduleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Name
            TextFormField(
              controller: _moduleNameController,
              decoration: InputDecoration(
                labelText: 'Module Name *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter module name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // // Medium
            // DropdownButtonFormField<String>(
            //   value: _selectedModuleMedium,
            //   decoration: InputDecoration(
            //     labelText: 'Medium *',
            //     labelStyle: TextStyle(color: AppColors.primary),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   items: _mediums.map((String medium) {
            //     return DropdownMenuItem<String>(
            //       value: medium,
            //       child: Text(medium),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       _selectedModuleMedium = newValue!;
            //     });
            //   },
            // ),
            // SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _moduleDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter module description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Icon
            DropdownButtonFormField<String>(
              value: _selectedModuleIcon,
              decoration: InputDecoration(
                labelText: 'Icon *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _moduleIcons.map((String icon) {
                return DropdownMenuItem<String>(
                  value: icon,
                  child: Row(
                    children: [
                      Icon(_getModuleIcon(icon)),
                      SizedBox(width: 8),
                      Text(icon),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModuleIcon = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Order
            DropdownButtonFormField<int>(
              value: _selectedOrder,
              decoration: InputDecoration(
                labelText: 'Display Order *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: List.generate(10, (index) => index + 1).map((int order) {
                return DropdownMenuItem<int>(
                  value: order,
                  child: Text('$order'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedOrder = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Is Active
            SwitchListTile(
              title: Text('Active Module'),
              subtitle: Text('Make this module available for selection'),
              value: _isModuleActive,
              onChanged: (bool value) {
                setState(() {
                  _isModuleActive = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isModuleLoading ? null : _addModule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isModuleLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      )
                    : Text(
                        'Add Module',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
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
                onPressed: _downloadUsersCsv,
                // onPressed: () => _downloadUsersExcel(context),
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
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found.'));
                }
                final users = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(user['name'] ?? 'No Name'),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: Text(
                        user['subscription']?.toString()?.toUpperCase() ??
                            'FREE',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Promo Code Tab
  Widget _buildAddPromoCodeTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _promoCodeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promo Code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _downloadPromodoesCsv,
                  // onPressed: () => _downloadUsersExcel(context),
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
            TextFormField(
              controller: _promoCodeController,
              decoration: InputDecoration(
                labelText: 'Promo Code *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter promo code';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _promoDescriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPromoLoading ? null : _addPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPromoLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      )
                    : Text(
                        'Add Promo Code',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadUsersExcel(BuildContext context) async {
    try {
      // Request permissions
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.request();
        if (!storagePermission.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required')),
            );
          }
          return;
        }
      }

      // Fetch user data
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final users = snapshot.docs.map((doc) => doc.data()).toList();
      if (users.isEmpty) return;

      // Create Excel
      final excel = Excel.createExcel();
      final sheet = excel['Users'];

      // Add headers
      sheet.appendRow([
        TextCellValue('Name'),
        TextCellValue('Email'),
        TextCellValue('Subscription'),
        TextCellValue('Referral Code'),
        TextCellValue('Created At'),
      ]);

      // Fill data
      for (final user in users) {
        sheet.appendRow([
          TextCellValue(user['name']?.toString() ?? ''),
          TextCellValue(user['email']?.toString() ?? ''),
          TextCellValue(user['subscription']?.toString() ?? ''),
          TextCellValue(user['referralCode']?.toString() ?? ''),
          TextCellValue(
            user['createdAt'] != null
                ? (user['createdAt'] as Timestamp).toDate().toIso8601String()
                : '',
          ),
        ]);
      }

      final excelBytes = excel.encode();
      if (excelBytes == null) throw Exception('Failed to encode Excel');

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'users_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final tempFilePath = '${tempDir.path}/$fileName';
      final file = File(tempFilePath);
      await file.writeAsBytes(excelBytes);

      // Save to Downloads using media_store_plus
      final mediaStore = MediaStore();
      final result = await mediaStore.saveFile(
        tempFilePath: tempFilePath,
        dirType: DirType.download,
        // fileName: fileName, // Fixed: Added missing fileName parameter
        dirName: DirName.download, // Fixed: Use DirName enum instead of string
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel saved to Downloads: $fileName'),
          ), // Fixed: Added fileName to message
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save Excel file.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _downloadUsersCsv() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final users = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    if (users.isEmpty) return;

    final headers = [
      'Name',
      'Email',
      'Subscription',
      'Referral Code',
      'Created At',
    ];
    final rows = [
      headers.join(','),
      ...users.map(
        (u) => [
          '"${u['name'] ?? ''}"',
          '"${u['email'] ?? ''}"',
          '"${u['subscription'] ?? ''}"',
          '"${u['referralCode'] ?? ''}"',
          '"${u['createdAt']?.toDate()?.toString() ?? ''}"',
        ].join(','),
      ),
    ];
    final csv = rows.join('\n');

    // For web, trigger download. For mobile, share/save file (not implemented here)
    // This example uses clipboard for simplicity
    await Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV copied to clipboard! Paste into Excel.')),
    );
  }

  Future<void> _downloadPromodoesCsv() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('promocodes')
        .get();
    final users = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    if (users.isEmpty) return;

    final headers = ['code', 'createdAt', 'description'];
    final rows = [
      headers.join(','),
      ...users.map(
        (u) => [
          '"${u['code'] ?? ''}"',
          '"${u['description'] ?? ''}"',
          '"${u['createdAt']?.toDate()?.toString() ?? ''}"',
        ].join(','),
      ),
    ];
    final csv = rows.join('\n');

    // For web, trigger download. For mobile, share/save file (not implemented here)
    // This example uses clipboard for simplicity
    await Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV copied to clipboard! Paste into Excel.')),
    );
  }

  Future<void> _addPromoCode() async {
    if (!_promoCodeFormKey.currentState!.validate()) return;
    setState(() {
      _isPromoLoading = true;
    });
    try {
      final promoData = {
        'code': _promoCodeController.text.trim(),
        'description': _promoDescriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('promocodes').add(promoData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Promo code added!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _promoCodeFormKey.currentState!.reset();
      _promoCodeController.clear();
      _promoDescriptionController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding promo code: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isPromoLoading = false;
      });
    }
  }

  IconData _getModuleIcon(String iconName) {
    switch (iconName) {
      case 'question_answer_outlined':
        return Icons.question_answer_outlined;
      case 'home_work_outlined':
        return Icons.home_work_outlined;
      case 'quiz_sharp':
        return Icons.quiz_sharp;
      case 'book':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'assignment':
        return Icons.assignment;
      case 'description':
        return Icons.description;
      case 'article':
        return Icons.article;
      case 'library_books':
        return Icons.library_books;
      case 'folder':
      default:
        return Icons.folder;
    }
  }
}
