/// OAuth Configuration for QuitForBit
/// Contains Google OAuth client IDs for all platforms
class OAuthConfig {
  // Google OAuth Client IDs
  static const String googleClientIdIOS =
      '421608251376-fi6e8rk58bpld5iqat1elt3t8uagvjd9.apps.googleusercontent.com';
  static const String googleClientIdWeb =
      '453880280823-ue44m8b0m2f5sa2fkcfh6l9bdcli31hl.apps.googleusercontent.com';
  static const String googleClientIdAndroid =
      '421608251376-qq2dnfttb6q9kh5gj3l8f5cbjdprvuge.apps.googleusercontent.com';

  // Get the appropriate client ID based on platform
  static String get googleClientId {
    // For web platform, return web client ID
    // For mobile platforms, this will be handled by platform-specific configs
    return googleClientIdWeb;
  }

  // Project information
  static const String projectNumber = '421608251376';
  static const String firebaseProjectId = 'quitforbit';
}
