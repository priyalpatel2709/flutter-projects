import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Sample modules data based on firestore_modules_schema.md
final List<Map<String, dynamic>> sampleModules = [
  {
    "name": "Imp Questions",
    "medium": "Gujarati",
    "description": "Important questions and solutions for exam preparation",
    "icon": "question_answer_outlined",
    "color": "primary",
    "backgroundColor": "primaryShade50",
    "isActive": true,
    "order": 1,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
  {
    "name": "Self Practice",
    "medium": "Gujarati",
    "description": "Practice exercises and worksheets for self-study",
    "icon": "home_work_outlined",
    "color": "secondary",
    "backgroundColor": "premiumLight",
    "isActive": true,
    "order": 2,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
  {
    "name": "Paper Seat",
    "medium": "Gujarati",
    "description": "Previous year papers and mock tests",
    "icon": "quiz_sharp",
    "color": "success",
    "backgroundColor": "successLight",
    "isActive": true,
    "order": 3,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
  {
    "name": "Imp Questions",
    "medium": "English",
    "description": "Important questions and solutions for exam preparation",
    "icon": "question_answer_outlined",
    "color": "primary",
    "backgroundColor": "primaryShade50",
    "isActive": true,
    "order": 1,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
  {
    "name": "Self Practice",
    "medium": "English",
    "description": "Practice exercises and worksheets for self-study",
    "icon": "home_work_outlined",
    "color": "secondary",
    "backgroundColor": "premiumLight",
    "isActive": true,
    "order": 2,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
  {
    "name": "Paper Seat",
    "medium": "English",
    "description": "Previous year papers and mock tests",
    "icon": "quiz_sharp",
    "color": "success",
    "backgroundColor": "successLight",
    "isActive": true,
    "order": 3,
    "createdAt": FieldValue.serverTimestamp(),
    "updatedAt": FieldValue.serverTimestamp(),
  },
];

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  print('Starting to import sample modules data...');
  
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    int successCount = 0;
    int errorCount = 0;
    
    for (Map<String, dynamic> moduleData in sampleModules) {
      try {
        // Add document to Firestore
        await firestore.collection('modules').add(moduleData);
        print('✓ Added: ${moduleData['name']} (${moduleData['medium']})');
        successCount++;
      } catch (e) {
        print('✗ Error adding ${moduleData['name']}: $e');
        errorCount++;
      }
    }
    
    print('\n=== Import Summary ===');
    print('Successfully added: $successCount modules');
    print('Errors: $errorCount modules');
    print('Total processed: ${sampleModules.length} modules');
    
  } catch (e) {
    print('Error during import: $e');
  }
  
  print('\nImport completed!');
} 