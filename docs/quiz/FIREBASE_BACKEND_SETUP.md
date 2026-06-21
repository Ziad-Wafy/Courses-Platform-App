# 🚀 Quiz Feature - Firebase Backend Requirements

As the person responsible for the Firebase backend for this feature, you need to ensure these three configurations are applied in the [Firebase Console](https://console.firebase.google.com/).

---

## **1. Cloud Firestore Setup**
The feature uses two main collections. You don't need to create them manually, but you MUST set the **Security Rules**.

### **Firestore Security Rules**
Go to **Firestore Database > Rules** and publish the following:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Quizzes: Teachers can create, students can read.
    // For simplicity in this project, we allow all authenticated users.
    match /quizzes/{quizId} {
      allow read, write: if request.auth != null;
    }
    
    // Quiz Results: Critical for privacy.
    // Students can write their results, but only read their OWN.
    match /quiz_results/{resultId} {
      allow write: if request.auth != null;
      allow read: if request.auth != null && request.auth.uid == resource.data.studentId;
    }
  }
}
```

---

## **2. Composite Indexes**
To allow the "Quizzes & Assessments" screen to show a student's history sorted by date, Firestore might require an index.

**If the app shows a console error with a link, click it.** Otherwise, you can manually create it:
- **Collection ID:** `quiz_results`
- **Fields to index:**
  - `studentId` (Ascending)
  - `completedAt` (Descending)
- **Query Scope:** Collection

---

## **3. Authentication Configuration**
Ensure that **Email/Password** provider is enabled in the **Authentication > Sign-in method** tab, as the Quiz feature relies on `request.auth.uid` to identify the student and save their scores securely.

---

## **4. Data Verification**
You can verify the data is being saved correctly by checking the collections after a test run:
- **`quizzes`**: Check that `questions` array is correctly populated with `options` and `correctAnswerId`.
- **`quiz_results`**: Verify `scorePercentage` is calculated and `passed` is a boolean.

---
**Status:** Backend configuration ready for integration.
