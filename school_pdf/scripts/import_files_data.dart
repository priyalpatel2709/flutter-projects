import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Sample data based on firestore_files_schema.md
final List<Map<String, dynamic>> sampleFiles = [
  {
    "name": "Algebra Basics.pdf",
    "fileId": "14p-grIGwA6YtAj-NyhqsnPBx3_URd1kE",
    "type": "pdf",
    "isFree": true,
    "medium": "Gujarati",
    "module": "Imp Questions",
    "description": "Basic algebra concepts and formulas",
    "uploadDate": DateTime.now(),
    "fileSize": "2.5MB",
    "downloads": 150,
    "tags": ["algebra", "mathematics", "basics"]
  },
  {
    "name": "Geometry Formulas.xlsx",
    "fileId": "1mGVAMTKSfM4e5eHy6RdBmOmhVaB2hr7HpgAqhRrJmTo",
    "type": "spreadsheet",
    "isFree": true,
    "medium": "Gujarati",
    "module": "Imp Questions",
    "description": "Complete geometry formulas and examples",
    "uploadDate": DateTime.now(),
    "fileSize": "1.8MB",
    "downloads": 89,
    "tags": ["geometry", "formulas", "mathematics"]
  },
  {
    "name": "Calculus Notes.pdf",
    "fileId": "1Hh9GQXsFGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
    "type": "pdf",
    "isFree": false,
    "medium": "Gujarati",
    "module": "Imp Questions",
    "description": "Advanced calculus concepts and problems",
    "uploadDate": DateTime.now(),
    "fileSize": "4.2MB",
    "downloads": 45,
    "tags": ["calculus", "advanced", "mathematics"]
  },
  {
    "name": "Physics Lab Report.pdf",
    "fileId": "1KGgHtTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
    "type": "pdf",
    "isFree": true,
    "medium": "Gujarati",
    "module": "Self Practice",
    "description": "Physics laboratory experiments and reports",
    "uploadDate": DateTime.now(),
    "fileSize": "3.0MB",
    "downloads": 67,
    "tags": ["physics", "lab", "experiments"]
  },
  {
    "name": "Chemistry Experiments.pptx",
    "fileId": "2ABCdEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmn",
    "type": "presentation",
    "isFree": false,
    "medium": "Gujarati",
    "module": "Self Practice",
    "description": "Chemistry experiment presentations",
    "uploadDate": DateTime.now(),
    "fileSize": "5.1MB",
    "downloads": 34,
    "tags": ["chemistry", "experiments", "presentation"]
  },
  {
    "name": "Grammar Rules.pdf",
    "fileId": "4GHIjKLMNOPQRSTUVWXYZabcdefghijklmnopqr",
    "type": "pdf",
    "isFree": true,
    "medium": "Gujarati",
    "module": "Paper Seat",
    "description": "English grammar rules and examples",
    "uploadDate": DateTime.now(),
    "fileSize": "2.1MB",
    "downloads": 120,
    "tags": ["grammar", "english", "rules"]
  },
  {
    "name": "Programming Basics.pdf",
    "fileId": "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
    "type": "pdf",
    "isFree": true,
    "medium": "English",
    "module": "Imp Questions",
    "description": "Introduction to programming concepts",
    "uploadDate": DateTime.now(),
    "fileSize": "3.1MB",
    "downloads": 120,
    "tags": ["programming", "basics", "computer-science"]
  },
  {
    "name": "Data Structures.pptx",
    "fileId": "7MNOpQRSTUVWXYZabcdefghijklmnopqrstu",
    "type": "presentation",
    "isFree": true,
    "medium": "English",
    "module": "Imp Questions",
    "description": "Data structures and algorithms presentation",
    "uploadDate": DateTime.now(),
    "fileSize": "4.5MB",
    "downloads": 78,
    "tags": ["data-structures", "algorithms", "computer-science"]
  },
  {
    "name": "World History Timeline.pdf",
    "fileId": "9RSTsTUVWXYZabcdefghijklmnopqrstuvw",
    "type": "pdf",
    "isFree": true,
    "medium": "English",
    "module": "Self Practice",
    "description": "Complete world history timeline",
    "uploadDate": DateTime.now(),
    "fileSize": "6.2MB",
    "downloads": 95,
    "tags": ["history", "timeline", "world-history"]
  },
  {
    "name": "World Map Atlas.pdf",
    "fileId": "2VWXvWXYZabcdefghijklmnopqrstuvwxyz",
    "type": "pdf",
    "isFree": true,
    "medium": "English",
    "module": "Paper Seat",
    "description": "Comprehensive world map atlas",
    "uploadDate": DateTime.now(),
    "fileSize": "8.7MB",
    "downloads": 156,
    "tags": ["geography", "maps", "atlas"]
  }
];

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  print('Starting to import sample files data...');
  
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    int successCount = 0;
    int errorCount = 0;
    
    for (Map<String, dynamic> fileData in sampleFiles) {
      try {
        // Add document to Firestore
        await firestore.collection('files').add(fileData);
        print('✓ Added: ${fileData['name']}');
        successCount++;
      } catch (e) {
        print('✗ Error adding ${fileData['name']}: $e');
        errorCount++;
      }
    }
    
    print('\n=== Import Summary ===');
    print('Successfully added: $successCount files');
    print('Errors: $errorCount files');
    print('Total processed: ${sampleFiles.length} files');
    
  } catch (e) {
    print('Error during import: $e');
  }
  
  print('\nImport completed!');
} 