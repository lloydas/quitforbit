# 🐛 Debug Google & Apple Sign-in Issues

## 🔍 **Getting Detailed Logs**

### **1. Enable Debug Logging in Flutter**
Add this to your main app to see detailed authentication logs:

```dart
// Add to lib/main.dart before runApp()
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug logging
  if (kDebugMode) {
    developer.log('🚀 Starting QuitForBit with debug logging');
  }
  
  // Rest of your initialization...
}
```

### **2. Run with Verbose Logging**
```bash
flutter run -d web-server --web-hostname localhost --web-port 8080 --verbose
```

### **3. Check Browser Console**
- Open Developer Tools (F12)
- Go to Console tab
- Look for error messages when clicking sign-in buttons

## 🔧 **Common Google Sign-in Issues**

### **Issue 1: OAuth Client ID Not Configured**
**Error:** `"Error 400: redirect_uri_mismatch"`

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Go to APIs & Services → Credentials
4. Find your OAuth 2.0 Client ID
5. Add these to "Authorized JavaScript origins":
   - `http://localhost:8080`
   - `https://quitforbit.firebaseapp.com`
6. Add this to "Authorized redirect URIs":
   - `https://quitforbit.firebaseapp.com/__/auth/handler`

### **Issue 2: Google Sign-in Not Enabled in Firebase**
**Error:** `"This app is not authorized to use Google Sign-In"`

**Solution:**
1. Go to Firebase Console → Authentication
2. Sign-in method tab
3. Click "Google" → Enable
4. Add your web client ID from Google Cloud Console

### **Issue 3: Web Client ID Missing**
**Error:** `"No web client ID found"`

**Solution:** Add this to your `web/index.html`:
```html
<script src="https://apis.google.com/js/platform.js" async defer></script>
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

## 🍎 **Common Apple Sign-in Issues**

### **Issue 1: Apple Sign-in Not Available on Web**
**Error:** `"Sign in with Apple is not supported"`

**Note:** Apple Sign-in has limited web support. It works on:
- ✅ iOS devices
- ✅ macOS devices  
- ❌ Web browsers (limited)

**Solution:** Test on iOS/macOS or add email/password as fallback

### **Issue 2: Apple Developer Configuration Missing**
**Error:** `"Invalid client configuration"`

**Solution:**
1. Go to [Apple Developer Console](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. Create/configure Sign in with Apple
4. Add your domain: `quitforbit.firebaseapp.com`

### **Issue 3: Bundle ID Mismatch**
**Error:** `"Bundle ID does not match"`

**Solution:** Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.quitforbit.app</string>
```

## 🚨 **Quick Debug Steps**

### **Step 1: Test Firebase Connection**
Add this test button to your auth screen:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test')
          .set({'timestamp': DateTime.now()});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Firebase connected!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Firebase error: $e')),
      );
    }
  },
  child: Text('Test Firebase'),
),
```

### **Step 2: Check Browser Network Tab**
1. Open DevTools → Network tab
2. Click Google/Apple sign-in
3. Look for failed requests (red entries)
4. Check response details for error messages

### **Step 3: Verify Firebase Project Settings**
1. Firebase Console → Project Settings
2. General tab → Your apps
3. Verify Web app configuration matches `firebase_options.dart`

## 🛠️ **Enhanced Error Handling**

### **Update AuthService with Better Logging:**

```dart
// Add to lib/services/auth/auth_service.dart

Future<UserCredential?> signInWithGoogle() async {
  try {
    print('🔍 Starting Google sign-in...');
    
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print('📧 Google user: ${googleUser?.email}');
    
    if (googleUser == null) {
      print('❌ User cancelled Google sign-in');
      return null;
    }

    print('🔑 Getting Google authentication...');
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    print('🔗 Creating Firebase credential...');
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print('🔥 Signing in to Firebase...');
    final result = await _auth.signInWithCredential(credential);
    print('✅ Google sign-in successful: ${result.user?.email}');
    
    return result;
  } catch (e, stackTrace) {
    print('❌ Google sign-in error: $e');
    print('📍 Stack trace: $stackTrace');
    rethrow;
  }
}

Future<UserCredential?> signInWithApple() async {
  try {
    print('🔍 Starting Apple sign-in...');
    
    // Check if Apple Sign-in is available
    if (!await SignInWithApple.isAvailable()) {
      print('❌ Apple Sign-in not available on this platform');
      throw Exception('Apple Sign-in not available');
    }
    
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    print('🔑 Generated nonce for Apple sign-in');

    print('🍎 Requesting Apple credential...');
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    print('📧 Apple credential received: ${appleCredential.email}');

    print('🔗 Creating Firebase credential...');
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    print('🔥 Signing in to Firebase...');
    final result = await _auth.signInWithCredential(oauthCredential);
    print('✅ Apple sign-in successful: ${result.user?.email}');
    
    return result;
  } catch (e, stackTrace) {
    print('❌ Apple sign-in error: $e');
    print('📍 Stack trace: $stackTrace');
    rethrow;
  }
}
```

## 🎯 **Most Likely Issues**

### **For Web Testing:**
1. **Google OAuth not configured** for localhost
2. **Apple Sign-in limited** on web browsers
3. **CORS issues** with Firebase
4. **Missing web client ID** in Google setup

### **Quick Fix for Web Testing:**
Use **email/password authentication** for initial testing:

```dart
// Temporary email/password for testing
Future<void> _testEmailAuth() async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'test@quitforbit.com',
      password: 'testpass123',
    );
    print('✅ Email auth works: ${credential.user?.email}');
  } catch (e) {
    print('❌ Email auth error: $e');
  }
}
```

## 📱 **Platform-Specific Testing**

### **Web Browser (Limited):**
- Google: ✅ Should work with proper OAuth setup
- Apple: ❌ Limited support

### **iOS Simulator/Device:**
- Google: ✅ Full support
- Apple: ✅ Full support

### **Android Emulator/Device:**
- Google: ✅ Full support  
- Apple: ❌ Not available

## 🚀 **Next Steps**

1. **Add the enhanced logging code** above
2. **Run the app** and check console output
3. **Share the specific error messages** you're seeing
4. **Test Firebase connection** first
5. **Configure OAuth properly** in Google Cloud Console

**What specific error messages are you seeing in the browser console or Flutter logs?** 