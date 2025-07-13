import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/module.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
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
  String _selectedModule = 'Imp Questions';
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
  final List<String> _mediums = ['Gujarati', 'English'];
  final List<String> _modules = [
    'Imp Questions',
    'Self Practice',
    'Paper Seat',
  ];
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> _addFile() async {
    if (!_fileFormKey.currentState!.validate()) return;

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
        'tags': [],
      };

      await FirebaseFirestore.instance.collection('files').add(fileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      _fileFormKey.currentState!.reset();
      _fileNameController.clear();
      _fileIdController.clear();
      _fileDescriptionController.clear();
      _fileSizeController.clear();
      setState(() {
        _selectedType = 'pdf';
        _selectedMedium = 'Gujarati';
        _selectedModule = 'Imp Questions';
        _isFree = true;
      });
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Module added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

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
            Tab(text: 'Add File'),
            Tab(text: 'Add Module'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAddFileTab(theme), _buildAddModuleTab(theme)],
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

            TextFormField(
              controller: _fileIdController,
              decoration: InputDecoration(
                labelText: 'Google Drive File ID *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Get this from the Google Drive URL',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter file ID';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

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

            DropdownButtonFormField<String>(
              value: _selectedMedium,
              decoration: InputDecoration(
                labelText: 'Medium *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _mediums.map((String medium) {
                return DropdownMenuItem<String>(
                  value: medium,
                  child: Text(medium),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMedium = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedModule,
              decoration: InputDecoration(
                labelText: 'Module *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _modules.map((String module) {
                return DropdownMenuItem<String>(
                  value: module,
                  child: Text(module),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModule = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

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

            DropdownButtonFormField<String>(
              value: _selectedModuleMedium,
              decoration: InputDecoration(
                labelText: 'Medium *',
                labelStyle: TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _mediums.map((String medium) {
                return DropdownMenuItem<String>(
                  value: medium,
                  child: Text(medium),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModuleMedium = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

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
