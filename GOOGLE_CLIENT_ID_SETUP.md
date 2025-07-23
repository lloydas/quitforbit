# 🔑 Google Client ID Setup - URGENT FIX NEEDED

## 🚨 **Current Issue**
```
❌ DEBUG: Google sign-in error: ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, or pass clientId when initializing GoogleSignIn
```

## ✅ **How to Fix Google Sign-in**

### **Step 1: Get Your Google OAuth Client ID**

1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Select your project** (probably auto-created when you set up Firebase)
3. **Navigate to APIs & Services** → **Credentials**
4. **Look for OAuth 2.0 Client IDs**
   - You should see one that looks like: `453880280823-xxxxxxxxxxxxxxxxx.apps.googleusercontent.com`
   - **Copy this entire string**

### **Step 2: Update Your Code**

**Replace the placeholder in TWO places:**

#### **A) In `web/index.html`:**
```html
<!-- REPLACE THIS LINE: -->
<meta name="google-signin-client_id" content="453880280823-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com">

<!-- WITH YOUR ACTUAL CLIENT ID: -->
<meta name="google-signin-client_id" content="453880280823-YOUR_ACTUAL_CLIENT_ID_HERE.apps.googleusercontent.com">
```

#### **B) In `lib/services/auth/auth_service.dart`:**
```dart
// REPLACE THIS LINE:
clientId: '453880280823-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com',

// WITH YOUR ACTUAL CLIENT ID:
clientId: '453880280823-YOUR_ACTUAL_CLIENT_ID_HERE.apps.googleusercontent.com',
```

### **Step 3: Configure OAuth Settings**

In **Google Cloud Console** → **Credentials** → **Your OAuth Client**:

1. **Authorized JavaScript origins:**
   - Add: `http://localhost:8080`
   - Add: `https://quitforbit.firebaseapp.com`
   - Add: `https://quitforbit.web.app`

2. **Authorized redirect URIs:**
   - Add: `https://quitforbit.firebaseapp.com/__/auth/handler`

### **Step 4: Enable Firebase Authentication**

In **Firebase Console** → **Authentication** → **Sign-in method**:

1. **Click "Google"** → **Enable**
2. **Paste your Web client ID** from Google Cloud Console
3. **Save**

## 🔧 **Additional Fixes Needed**

### **Fix Firestore Security Rules**

In **Firebase Console** → **Firestore Database** → **Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Allow authenticated users to read/write transactions and milestones
    match /bitcoin_transactions/{transactionId} {
      allow read, write: if request.auth != null;
    }
    match /milestones/{milestoneId} {
      allow read, write: if request.auth != null;
    }
    // Allow test writes for debugging
    match /test/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **Enable Email/Password Authentication (Optional)**

In **Firebase Console** → **Authentication** → **Sign-in method**:
- **Click "Email/Password"** → **Enable** → **Save**

## 🎯 **Quick Test Steps**

1. **Update both files** with your real Google Client ID
2. **Refresh the web app**
3. **Click "Test Firebase"** → Should show green success
4. **Click "Continue with Google"** → Should open Google OAuth popup
5. **Sign in with Google** → Should navigate to onboarding

## 🔍 **If You Can't Find Your Google Client ID**

**Create a new one:**

1. **Google Cloud Console** → **APIs & Services** → **Credentials**
2. **Create Credentials** → **OAuth client ID**
3. **Web application**
4. **Name**: `QuitForBit Web`
5. **Authorized JavaScript origins**: `http://localhost:8080`, `https://quitforbit.firebaseapp.com`
6. **Create** → **Copy the Client ID**

## 🚀 **Expected Result**

After fixing the Client ID:
```
✅ DEBUG: Google sign-in successful: user@gmail.com
```

**This is the critical fix needed to get Google authentication working!** 🔑 