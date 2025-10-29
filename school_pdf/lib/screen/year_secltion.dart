import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pdf/screen/drivefiles_screen.dart';
import '../constants/app_colors.dart';

class YearSelectionScreen extends StatefulWidget {
  final String title;
  final String medium;
  final String module;

  const YearSelectionScreen({
    super.key,
    required this.title,
    required this.medium,
    required this.module,
  });

  @override
  State<YearSelectionScreen> createState() => _YearSelectionScreenState();
}

class _YearSelectionScreenState extends State<YearSelectionScreen> {
  bool isLoading = true;
  List<String> availableYears = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableYears();
  }

  Future<void> _loadAvailableYears() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Query files from Firestore based on medium and module
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where('medium', isEqualTo: widget.medium)
          .where('module', isEqualTo: widget.module)
          .get();

      Set<String> years = {};

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tags = data['tags'] as List<dynamic>?;

        if (tags != null) {
          for (var tag in tags) {
            String tagStr = tag.toString();
            if (tagStr.contains('2023')) years.add('2023');
            if (tagStr.contains('2024')) years.add('2024');
            if (tagStr.contains('2025')) years.add('2025');
            if (tagStr.contains('2026')) years.add('2026');
          }
        }
      }

      setState(() {
        availableYears = years.toList()
          ..sort((a, b) => b.compareTo(a)); // Sort descending
        isLoading = false;
      });
    } catch (e) {
      print('Error loading years: $e');
      setState(() {
        isLoading = false;
        availableYears = [];
      });
    }
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
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadAvailableYears),
        ],
      ),
      body: isLoading
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
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
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
                                'Select Year',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${availableYears.length} years available',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Years List
                  Expanded(
                    child: availableYears.isEmpty
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
                                  'No years available',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Papers will be added soon',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableYears.length,
                            itemBuilder: (context, index) {
                              final year = availableYears[index];

                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shadowColor: AppColors.shadowLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.folder,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  title: Text(
                                    'Year $year',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'View papers for $year',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    // Navigate to DriveFilesScreen with selected year
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DriveFilesScreen(
                                          title: '${widget.title} - $year',
                                          medium: widget.medium,
                                          module: widget.module,
                                          selectedYear: year,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
