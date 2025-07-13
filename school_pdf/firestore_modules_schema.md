# Firestore Modules Collection Schema

## Collection: `modules`

Each document in the `modules` collection represents a module that can be selected by users.

### Document Structure:

```json
{
  "name": "Imp Questions",
  "medium": "Gujarati",
  "description": "Important questions and solutions for exam preparation",
  "icon": "question_answer_outlined",
  "color": "primary",
  "backgroundColor": "primaryShade50",
  "isActive": true,
  "order": 1,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Field Descriptions:

- **name** (string, required): Display name of the module
- **medium** (string, required): Language medium (Gujarati, English)
- **description** (string, required): Module description for display
- **icon** (string, required): Material icon name (without Icons.)
- **color** (string, required): Theme color name (primary, secondary, success, etc.)
- **backgroundColor** (string, required): Background color name for styling
- **isActive** (boolean, required): Whether the module is available for selection
- **order** (number, required): Display order (1, 2, 3, etc.)
- **createdAt** (timestamp, optional): When the module was created
- **updatedAt** (timestamp, optional): When the module was last updated

### Sample Data:

```json
// Document 1 - Gujarati Imp Questions
{
  "name": "Imp Questions",
  "medium": "Gujarati",
  "description": "Important questions and solutions for exam preparation",
  "icon": "question_answer_outlined",
  "color": "primary",
  "backgroundColor": "primaryShade50",
  "isActive": true,
  "order": 1,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Document 2 - Gujarati Self Practice
{
  "name": "Self Practice",
  "medium": "Gujarati",
  "description": "Practice exercises and worksheets for self-study",
  "icon": "home_work_outlined",
  "color": "secondary",
  "backgroundColor": "premiumLight",
  "isActive": true,
  "order": 2,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Document 3 - Gujarati Paper Seat
{
  "name": "Paper Seat",
  "medium": "Gujarati",
  "description": "Previous year papers and mock tests",
  "icon": "quiz_sharp",
  "color": "success",
  "backgroundColor": "successLight",
  "isActive": true,
  "order": 3,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Document 4 - English Imp Questions
{
  "name": "Imp Questions",
  "medium": "English",
  "description": "Important questions and solutions for exam preparation",
  "icon": "question_answer_outlined",
  "color": "primary",
  "backgroundColor": "primaryShade50",
  "isActive": true,
  "order": 1,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Document 5 - English Self Practice
{
  "name": "Self Practice",
  "medium": "English",
  "description": "Practice exercises and worksheets for self-study",
  "icon": "home_work_outlined",
  "color": "secondary",
  "backgroundColor": "premiumLight",
  "isActive": true,
  "order": 2,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}

// Document 6 - English Paper Seat
{
  "name": "Paper Seat",
  "medium": "English",
  "description": "Previous year papers and mock tests",
  "icon": "quiz_sharp",
  "color": "success",
  "backgroundColor": "successLight",
  "isActive": true,
  "order": 3,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /modules/{moduleId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Indexes Required:

Create composite indexes for efficient querying:

1. **Collection**: `modules`
   - **Fields**: `modules` (Ascending), `order` (Ascending)
   - **Query**: `where('medium', '==', 'Gujarati') && where('isActive', '==', true)`

2. **Collection**: `modules`
   - **Fields**: `isActive` (Ascending), `medium` (Ascending), `order` (Ascending)
   - **Query**: For filtering active modules by medium

### Benefits of Separate Modules Collection:

✅ **Better Organization**: Modules are separate from files  
✅ **Easier Management**: Add/remove modules without affecting files  
✅ **Rich Metadata**: Store descriptions, icons, colors, order  
✅ **Active/Inactive Control**: Enable/disable modules  
✅ **Ordering**: Control display order of modules  
✅ **Performance**: Faster queries for module lists  
✅ **Scalability**: Easy to add new modules and mediums  

### Module Management:

- **Adding Modules**: Create new documents in the `modules` collection
- **Updating Modules**: Modify existing documents
- **Deactivating Modules**: Set `isActive` to `false`
- **Reordering**: Update the `order` field
- **Cross-medium**: Same module name can exist for different mediums 