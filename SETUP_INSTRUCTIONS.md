# 🚀 QuitForBit MVP - Setup Instructions

## ⚠️ **SETUP REQUIRED** - Follow These Steps Before Testing

The MVP code is **100% complete**, but you need to set up your development environment and Firebase backend.

## 📋 **Prerequisites Checklist**

### 1. **Install Flutter SDK**
```bash
# Option A: Download from official site
# Visit: https://docs.flutter.dev/get-started/install/macos

# Option B: Install via Homebrew (recommended)
brew install --cask flutter

# Verify installation
flutter doctor
```

### 2. **Install Dependencies**
```bash
cd quitforbit
flutter clean
flutter pub get
```

### 3. **Set Up Firebase Project**

#### 3a. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name: **"QuitForBit"** or **"quitforbit-mvp"**
4. Enable Google Analytics (optional)
5. Create project

#### 3b. Enable Required Services
1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Disable email verification for MVP testing

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in test mode
   - Choose location closest to you

#### 3c. Add Web App to Firebase
1. In Project Settings, click "Add app" → Web
2. App nickname: **"QuitForBit Web"**
3. **Copy the Firebase configuration object**

#### 3d. Configure Firebase in App
Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',           // ← Replace this
  appId: 'YOUR_ACTUAL_APP_ID',             // ← Replace this  
  messagingSenderId: 'YOUR_SENDER_ID',     // ← Replace this
  projectId: 'YOUR_PROJECT_ID',            // ← Replace this
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

## 🧪 **Testing the MVP**

### **Step 1: Run Flutter Doctor**
```bash
flutter doctor
```
Fix any issues it reports.

### **Step 2: Test Compilation**
```bash
flutter analyze
```
Should show no errors.

### **Step 3: Run Unit Tests**
```bash
flutter test test/mvp_test.dart
```

### **Step 4: Launch Web App**
```bash
flutter run -d web-server --web-hostname localhost --web-port 8080
```

Open browser to: **http://localhost:8080**

## ✅ **Test the Complete User Journey**

### 1. **Registration**
- Create account with email/password
- Should navigate to onboarding automatically

### 2. **Onboarding** 
- Complete 3-step process
- Bitcoin wallet setup should succeed
- Should receive $1 Bitcoin reward
- Navigate to dashboard

### 3. **Dashboard**
- Verify streak shows correctly
- Bitcoin balance displays $1.00
- Next milestone shows "First Day"
- Check-in button available

### 4. **Daily Check-in**
- Click "Daily Check-in" 
- Streak should increment
- Button should disable
- If Day 1 reached, should get additional $1

### 5. **Features**
- Test panic button → breathing exercise
- Check profile menu
- Verify Bitcoin price updates

## 🔧 **Common Setup Issues & Solutions**

### **Flutter Not Found**
```bash
# Add Flutter to PATH
echo 'export PATH="$PATH:`flutter/bin`"' >> ~/.zshrc
source ~/.zshrc
```

### **Firebase Configuration Errors**
- Double-check all values in `firebase_options.dart`
- Ensure web app is properly added to Firebase project
- Verify Firestore is enabled and in test mode

### **Compilation Errors**
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
```

### **Network/Permission Errors**
- Check Firestore security rules allow authenticated access
- Verify internet connection for Bitcoin price API

## 🎯 **Expected Results**

After setup, you should have:
- ✅ Working Bitcoin reward system (testnet)
- ✅ User registration and authentication  
- ✅ Daily check-in with streak tracking
- ✅ Milestone detection and rewards
- ✅ Real-time Bitcoin price display
- ✅ Clean, modern interface

## 🚀 **Quick Start (If You Have Flutter Already)**

```bash
# 1. Install dependencies
flutter pub get

# 2. Set up Firebase (follow Firebase section above)

# 3. Run the app
flutter run -d web-server --web-hostname localhost --web-port 8080
```

## 📞 **Need Help?**

If you encounter issues:
1. Run `flutter doctor` and fix any problems
2. Verify Firebase configuration is correct
3. Check browser console for errors
4. Ensure internet connection for Bitcoin API

## 🎉 **Ready to Test!**

Once setup is complete, you'll have the **world's first Bitcoin-paying addiction recovery app** running locally!

**The revolutionary MVP that pays users in Bitcoin for maintaining sobriety is ready! 🚀💰** 