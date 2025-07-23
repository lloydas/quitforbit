# QuitForBit MVP Implementation Plan

## 🎯 MVP Vision
**"Prove users will engage with Bitcoin-incentivized addiction recovery"**

Launch the simplest possible version that validates our core hypothesis: people will be more motivated to maintain recovery streaks when they earn real Bitcoin rewards.

## 🔥 Core Value Proposition (MVP)
**"Earn Bitcoin for every day you stay clean"**

## 📋 MVP Feature Set (Keep It Simple)

### ✅ MUST HAVE (MVP Core)

#### 1. Enhanced Streak Tracking
- [ ] Visual streak counter (days clean)
- [ ] Streak calendar view
- [ ] Daily check-in button
- [ ] Streak reset with compassionate messaging
- [ ] Basic progress charts

#### 2. Bitcoin Testnet Integration  
- [ ] Simple Bitcoin wallet setup
- [ ] Testnet Bitcoin rewards for milestones
- [ ] Clear reward schedule display
- [ ] Bitcoin balance tracking
- [ ] Basic withdrawal simulation

#### 3. Essential Authentication
- [ ] Email/password signup (no social auth for MVP)
- [ ] Basic profile setup
- [ ] Secure user sessions
- [ ] Password reset flow

#### 4. Minimal Onboarding
- [ ] Welcome & Bitcoin explanation (3 screens max)
- [ ] Goal setting (simple)
- [ ] Wallet setup walkthrough
- [ ] First reward ($1 Bitcoin for signup)

#### 5. Basic Milestone System
- [ ] Day 1: $1 Bitcoin (immediate gratification)
- [ ] Day 7: $5 Bitcoin  
- [ ] Day 30: $25 Bitcoin
- [ ] Simple notification system for rewards

#### 6. Panic Button
- [ ] Emergency support button
- [ ] Quick breathing exercise
- [ ] Motivational reminder
- [ ] Progress reminder (don't lose your Bitcoin!)

### ❌ EXCLUDE FROM MVP (V2 Features)

- Community features (forums, chat, accountability partners)
- Educational content library (just basic tips)
- Professional therapy integration
- Advanced analytics and insights
- Family/partner features
- Content blocking (use external apps)
- Cross-platform sync (web only for MVP)
- Advanced security features
- Multiple addiction types (porn only)
- Social features (sharing, leaderboards)
- AI-powered features
- Advanced milestone customization

## 🛠️ Technical Architecture (MVP)

### Frontend (Flutter Web)
- **Platform**: Web-only (avoid app store delays)
- **State Management**: Riverpod (existing)
- **Navigation**: Go Router (simple)
- **UI**: Material Design 3 (clean, minimal)

### Backend (Simplified)
- **Authentication**: Firebase Auth (email only)
- **Database**: Firestore (simplified schema)
- **Functions**: Cloud Functions (minimal)
- **Bitcoin**: BTCPay Server Testnet

### Data Models (Simplified)

```dart
// Minimal User Model
class User {
  String id;
  String email;
  String bitcoinAddress;
  int currentStreak;
  int longestStreak;
  double totalEarned;
  DateTime lastCheckIn;
  DateTime createdAt;
}

// Minimal Milestone Model  
class Milestone {
  String id;
  int dayTarget;
  double bitcoinAmount;
  DateTime? achievedAt;
  String status; // 'pending', 'achieved', 'paid'
}

// Basic Transaction Model
class Transaction {
  String id;
  String userId;
  double amount;
  String type; // 'milestone', 'signup'
  DateTime createdAt;
  String status; // 'pending', 'completed'
}
```

## 🎨 MVP User Flow

### 1. Landing Page
- Clear value proposition
- Bitcoin earning potential
- Simple email signup

### 2. Onboarding (3 screens)
- Screen 1: Welcome & concept explanation
- Screen 2: Bitcoin wallet setup  
- Screen 3: First milestone explanation

### 3. Dashboard (Single Screen)
- Current streak counter (large, prominent)
- Next milestone countdown
- Bitcoin balance
- Daily check-in button
- Panic button
- Simple progress chart

### 4. Check-in Flow
- "How are you feeling today?" (3 options: good, struggling, great)
- Streak increment
- Reward notification (if milestone reached)
- Encouragement message

### 5. Panic Button Flow
- Immediate intervention screen
- 60-second breathing exercise
- Motivational message about Bitcoin earnings
- Easy return to dashboard

## 📱 MVP Wireframes

```
┌─────────────────────────────────┐
│           Dashboard             │
├─────────────────────────────────┤
│                                 │
│        🔥 Day 23 🔥            │
│     (Large streak counter)      │
│                                 │
│    Next reward: 7 days left     │
│        $25 Bitcoin              │
│                                 │
│    💰 Balance: $6.00 BTC       │
│                                 │
│  [    Daily Check-in   ]        │
│                                 │
│  [   😰 Panic Button   ]        │
│                                 │
│    📊 Progress Chart            │
│                                 │
└─────────────────────────────────┘
```

## ⚡ 2-Week Sprint Plan

### Week 1: Core Infrastructure
**Days 1-2: Bitcoin Integration**
- [ ] Research BTCPay Server testnet setup
- [ ] Create basic Bitcoin wallet generation
- [ ] Test Bitcoin testnet transactions
- [ ] Simple balance tracking

**Days 3-4: Enhanced Streak System**
- [ ] Improve existing streak tracking
- [ ] Add milestone detection
- [ ] Create reward calculation logic
- [ ] Build notification system

**Days 5-7: UI/UX Improvement**
- [ ] Redesign dashboard with Bitcoin focus
- [ ] Create onboarding flow
- [ ] Build panic button feature
- [ ] Basic responsive design

### Week 2: Integration & Testing
**Days 8-9: Bitcoin Integration**
- [ ] Connect streak milestones to Bitcoin rewards
- [ ] Test full reward flow
- [ ] Add transaction history
- [ ] Error handling and edge cases

**Days 10-12: Polish & Testing**
- [ ] User testing with 5-10 beta users
- [ ] Bug fixes and UI polish
- [ ] Performance optimization
- [ ] Security review

**Days 13-14: Launch Preparation**
- [ ] Deploy to production
- [ ] Create simple landing page
- [ ] Basic analytics setup
- [ ] Launch to small group (20-50 users)

## 🧪 Success Metrics (MVP)

### Primary (Must Achieve)
- [ ] **User Activation**: 80% complete onboarding and get first Bitcoin reward
- [ ] **Engagement**: 60% daily check-in rate for first week
- [ ] **Retention**: 40% of users return after 7 days
- [ ] **Technical**: Zero Bitcoin transaction failures

### Secondary (Nice to Have)
- [ ] **Conversion**: 10% upgrade to paid plan (if we add premium features)
- [ ] **Referral**: 20% of users share the app
- [ ] **Feedback**: 4.0+ average user rating
- [ ] **Milestone**: 30% of users reach 7-day milestone

## 🚀 Launch Strategy (MVP)

### Beta Launch (Week 3)
- **Audience**: 50 hand-picked beta users
- **Channels**: Personal network, Reddit post, Twitter
- **Focus**: Product feedback and bug reports
- **Rewards**: Testnet Bitcoin only

### Public Launch (Week 4)
- **Audience**: 500 users
- **Channels**: Product Hunt, addiction recovery forums
- **Focus**: User acquisition and word-of-mouth
- **Rewards**: Real Bitcoin (small amounts)

### Growth Phase (Month 2)
- **Audience**: 2,000 users  
- **Channels**: Content marketing, influencer partnerships
- **Focus**: Product-market fit validation
- **Rewards**: Full milestone system

## ⚠️ MVP Constraints & Decisions

### Technical Constraints
- **Web-only**: Avoid app store approval delays
- **Testnet first**: Minimize Bitcoin risk
- **Single platform**: No mobile app until validation
- **Manual verification**: No automated fraud detection yet

### Feature Constraints  
- **No community**: Focus on individual journey
- **Basic content**: Essential info only
- **Simple milestones**: Standard day-based only
- **Limited customization**: One-size-fits-all approach

### Resource Constraints
- **2-week deadline**: Feature freeze after sprint
- **Solo development**: No team expansion until validation
- **Minimal marketing**: Organic growth only
- **Bootstrap budget**: Under $500 for MVP

## 🎯 Post-MVP Roadmap

### If MVP Succeeds (Month 2-3)
1. Mobile app development
2. Community features
3. Advanced Bitcoin features
4. Content library expansion
5. Professional integrations

### If MVP Fails (Pivot Options)
1. Traditional reward system (gift cards)
2. Focus on different addiction types
3. B2B wellness platform
4. Pure streak tracking app

## 🔧 Development Setup (Next Steps)

### Immediate Actions
1. [ ] Set up BTCPay Server testnet account
2. [ ] Update Firebase project configuration
3. [ ] Create new Flutter web build configuration
4. [ ] Set up basic CI/CD pipeline
5. [ ] Create development and staging environments

### First Code Changes
1. [ ] Update existing User model with Bitcoin fields
2. [ ] Create Milestone and Transaction models
3. [ ] Build Bitcoin service integration
4. [ ] Enhanced StreakProvider with milestones
5. [ ] New dashboard UI with Bitcoin focus

---

## 🎉 MVP Success Definition

**"50 users maintaining 7+ day streaks and earning their first Bitcoin rewards within 30 days of launch"**

This MVP strips everything down to the absolute essentials while preserving the revolutionary Bitcoin incentive concept. If this simple version proves user engagement and validates the core hypothesis, we can rapidly iterate and add features.

**Ready to build the world's first Bitcoin-powered addiction recovery app in 2 weeks? Let's get started! 🚀** 