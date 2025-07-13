# Firestore Files Collection Schema

## Collection: `files`

Each document in the `files` collection represents a file that can be accessed by users.

### Document Structure:

```json
{
  "name": "Algebra Basics.pdf",
  "fileId": "14p-grIGwA6YtAj-NyhqsnPBx3_URd1kE",
  "type": "pdf",
  "isFree": true,
  "medium": "Gujarati",
  "module": "Imp Questions",
  "description": "Basic algebra concepts and formulas",
  "uploadDate": "2024-01-15T10:30:00Z",
  "fileSize": "2.5MB",
  "downloads": 150,
  "tags": ["algebra", "mathematics", "basics"]
}
```

### Field Descriptions:

- **name** (string, required): Display name of the file
- **fileId** (string, required): Google Drive file ID
- **type** (string, required): File type (pdf, spreadsheet, presentation, image, document)
- **isFree** (boolean, required): Whether the file is free or requires premium subscription
- **medium** (string, required): Language medium (Gujarati, English)
- **module** (string, required): Module category (Imp Questions, Self Practice, Paper Seat)
- **description** (string, optional): File description
- **uploadDate** (timestamp, optional): When the file was uploaded
- **fileSize** (string, optional): File size for display
- **downloads** (number, optional): Number of times downloaded
- **tags** (array, optional): Search tags

### Sample Data:

```json
// Document 1
{
  "name": "Algebra Basics.pdf",
  "fileId": "14p-grIGwA6YtAj-NyhqsnPBx3_URd1kE",
  "type": "pdf",
  "isFree": true,
  "medium": "Gujarati",
  "module": "Imp Questions",
  "description": "Basic algebra concepts and formulas",
  "uploadDate": "2024-01-15T10:30:00Z",
  "fileSize": "2.5MB",
  "downloads": 150,
  "tags": ["algebra", "mathematics", "basics"]
}

// Document 2
{
  "name": "Geometry Formulas.xlsx",
  "fileId": "1mGVAMTKSfM4e5eHy6RdBmOmhVaB2hr7HpgAqhRrJmTo",
  "type": "spreadsheet",
  "isFree": true,
  "medium": "Gujarati",
  "module": "Imp Questions",
  "description": "Complete geometry formulas and examples",
  "uploadDate": "2024-01-16T14:20:00Z",
  "fileSize": "1.8MB",
  "downloads": 89,
  "tags": ["geometry", "formulas", "mathematics"]
}

// Document 3
{
  "name": "Calculus Notes.pdf",
  "fileId": "1Hh9GQXsFGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
  "type": "pdf",
  "isFree": false,
  "medium": "Gujarati",
  "module": "Imp Questions",
  "description": "Advanced calculus concepts and problems",
  "uploadDate": "2024-01-17T09:15:00Z",
  "fileSize": "4.2MB",
  "downloads": 45,
  "tags": ["calculus", "advanced", "mathematics"]
}

// Document 4
{
  "name": "Programming Basics.pdf",
  "fileId": "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
  "type": "pdf",
  "isFree": true,
  "medium": "English",
  "module": "Imp Questions",
  "description": "Introduction to programming concepts",
  "uploadDate": "2024-01-18T11:45:00Z",
  "fileSize": "3.1MB",
  "downloads": 120,
  "tags": ["programming", "basics", "computer-science"]
}
```

### Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /files/{fileId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Indexes Required:

Create composite indexes for efficient querying:

1. **Collection**: `files`
   - **Fields**: `medium` (Ascending), `module` (Ascending)
   - **Query**: `where('medium', '==', 'Gujarati') && where('module', '==', 'Imp Questions')`

2. **Collection**: `files`
   - **Fields**: `isFree` (Ascending), `medium` (Ascending), `module` (Ascending)
   - **Query**: For filtering free/premium content

### How to Add Files:

1. Upload your file to Google Drive
2. Get the file ID from the Google Drive URL
3. Create a new document in the `files` collection
4. Fill in all required fields
5. Set appropriate permissions in Google Drive (make sure it's accessible)

### File Permissions in Google Drive:

- For free files: Set to "Anyone with the link can view"
- For premium files: Set to "Anyone with the link can view" (access control handled by app) 