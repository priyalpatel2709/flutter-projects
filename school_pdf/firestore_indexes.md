# Firestore Indexes Required

This document lists all the Firestore indexes required for the app to function properly.

## Required Indexes

### 1. Referrals Collection Index
**Collection:** `referrals`  
**Fields:**
- `referrerId` (Ascending)
- `createdAt` (Descending)

**Purpose:** This index is required for the query in `ReferralService.getReferredUsers()` that filters by referrer ID and orders by creation date.

**Query that requires this index:**
```dart
.where('referrerId', isEqualTo: user.uid)
.orderBy('createdAt', descending: true)
```

### 2. Users Collection Index (Optional but Recommended)
**Collection:** `users`  
**Fields:**
- `referralCode` (Ascending)

**Purpose:** This index optimizes queries that search for users by referral code.

**Query that benefits from this index:**
```dart
.where('referralCode', isEqualTo: code)
```

## How to Create These Indexes

### Method 1: Using Firebase Console (Recommended)
1. Go to the Firebase Console: https://console.firebase.google.com/
2. Select your project: `school-bf32a`
3. Navigate to Firestore Database
4. Click on the "Indexes" tab
5. Click "Create Index"
6. For the referrals index:
   - Collection ID: `referrals`
   - Fields: 
     - `referrerId` (Ascending)
     - `createdAt` (Descending)
7. Click "Create"

### Method 2: Using the Error Link
When you get the index error, click on the provided link in the error message. It will take you directly to the Firebase Console with the correct index configuration pre-filled.

### Method 3: Using Firebase CLI
If you have Firebase CLI installed, you can create a `firestore.indexes.json` file:

```json
{
  "indexes": [
    {
      "collectionGroup": "referrals",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "referrerId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

Then run:
```bash
firebase deploy --only firestore:indexes
```

## Index Creation Time
- Index creation typically takes 1-5 minutes
- You can monitor the progress in the Firebase Console
- The app will work once the index is fully created

## Testing
After creating the indexes, test the referral functionality:
1. Navigate to the Referral screen
2. Check if the referred users list loads without errors
3. Verify that new referrals are properly tracked 