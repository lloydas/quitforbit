# 🏆 Milestone - Overcome Addiction with Bitcoin Rewards

A Flutter mobile application designed to help users overcome pornography addiction through streak tracking, educational content, and Bitcoin rewards for achieving milestones.

## 🌟 Features

### Free Tier
- **🔐 Secure Authentication**: Google & Apple Sign-in
- **📊 Streak Tracking**: Real-time counter (days, hours, minutes)
- **💥 Relapse Handling**: One-click reset with privacy
- **📱 Daily Reminders**: Encouraging notifications
- **🎓 Educational Onboarding**: Personalized assessment questionnaire

### Premium Tier
- **₿ Bitcoin Rewards**: Earn real BTC for reaching milestones
  - 30 days: 0.001 BTC (~$40-60)
  - 90 days: 0.0025 BTC (~$100-150)
  - 180 days: 0.005 BTC (~$200-300)
  - 365 days: 0.01 BTC (~$400-600)
- **💼 Wallet Integration**: Secure Bitcoin wallet management
- **📈 Advanced Analytics**: Historical data and patterns
- **👥 Community Access**: Anonymous support forum

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter 3.7.2+
- **State Management**: Riverpod
- **UI Components**: Material Design 3 with custom styling
- **Animations**: Smooth transitions and micro-interactions

### Backend & Services
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth (Google & Apple)
- **Cloud Functions**: Serverless backend logic
- **Analytics**: Firebase Analytics & Crashlytics
- **Notifications**: Firebase Cloud Messaging

### Monetization
- **Subscriptions**: RevenueCat (cross-platform)
- **Pricing**: $14.99/month or $99.99/year
- **Bitcoin Payouts**: Coinbase Commerce / BTCPay Server

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2+
- Firebase project with authentication enabled
- RevenueCat account for subscriptions
- Bitcoin payment provider account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/milestone-app.git
   cd milestone-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication (Google & Apple)
   - Enable Firestore Database
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Fill in your API keys and configuration values

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── core/
│   ├── constants/          # App constants and styling
│   ├── providers/          # Riverpod providers
│   ├── services/           # Core services
│   └── utils/              # Utility functions
├── models/                 # Data models
├── screens/                # App screens
│   ├── auth/              # Authentication
│   ├── onboarding/        # User onboarding
│   ├── dashboard/         # Main dashboard
│   └── settings/          # User settings
├── services/              # External services
│   ├── auth/              # Authentication service
│   ├── firestore/         # Database service
│   └── notifications/     # Push notifications
└── widgets/               # Reusable UI components
    ├── common/            # Common widgets
    └── charts/            # Chart components
```

## 🎨 Design System

### Colors
- **Primary**: #6C63FF (Purple)
- **Secondary**: #00D4AA (Teal)
- **Bitcoin**: #F7931A (Orange)
- **Success**: #10B981 (Green)
- **Error**: #EF4444 (Red)

### Typography
- **Font Family**: Poppins
- **Scales**: H1-H4, Subtitle1-2, Body1-2, Caption

### Spacing & Layout
- **Base Unit**: 8px
- **Padding Scale**: XS(4) → S(8) → M(16) → L(24) → XL(32) → XXL(48)
- **Border Radius**: S(8) → M(12) → L(16) → XL(24)

## 🔒 Security Considerations

### Data Privacy
- End-to-end encryption for sensitive data
- GDPR compliance
- Minimal data collection
- User-controlled data retention

### Financial Security
- Secure Bitcoin wallet integration
- Transaction logging and auditing
- Multi-factor authentication for premium features
- PCI compliance for payment processing

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test/
```

## 📦 Build & Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Environment-specific Builds
```bash
# Development
flutter build apk --flavor dev

# Production
flutter build apk --flavor prod
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📋 Roadmap

### Phase 1: Foundation (Current)
- ✅ Authentication system
- ✅ Educational onboarding
- ✅ Basic UI framework
- 🔄 Streak tracking logic
- ⏳ Dashboard implementation

### Phase 2: Monetization
- ⏳ RevenueCat integration
- ⏳ Subscription management
- ⏳ Paywall implementation

### Phase 3: Bitcoin Rewards
- ⏳ Crypto payment integration
- ⏳ Automated payout system
- ⏳ Wallet management

### Phase 4: Enhancement
- ⏳ Advanced analytics
- ⏳ Community features
- ⏳ Push notifications

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Email**: support@milestone-app.com
- **Documentation**: [docs.milestone-app.com](https://docs.milestone-app.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/milestone-app/issues)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- RevenueCat for subscription management
- The recovery community for inspiration and feedback

---

**Disclaimer**: This app is designed to support recovery efforts but is not a substitute for professional help. If you're struggling with addiction, please consider seeking support from qualified professionals.
