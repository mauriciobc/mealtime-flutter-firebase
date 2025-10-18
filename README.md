# MealTime - Smart Cat Feeding Management App

MealTime is a comprehensive Flutter application designed to streamline cat feeding routines, ensuring pets are fed consistently and responsibly. The app enables collaborative care among household members, offering configurable feeding schedules, real-time tracking, weight monitoring, and comprehensive analytics to promote feline health and household coordination.

## Features

### 🏠 Household & User Management
- Create/Join Households with invite codes
- Role-based access control (Admin, Member)
- Multi-user sync with real-time updates
- User preferences (language, timezone)

### 🐱 Cat Profile Management
- Detailed cat profiles with photos, birthdate, weight, dietary restrictions
- Grouping system for bulk actions
- Optional photo upload with placeholder fallback
- Medical notes and dietary restrictions tracking

### ⏰ Feeding Schedule Configuration
- Custom schedules (fixed intervals or specific times)
- Apply schedules to individual cats or groups
- Override options for holidays or vet recommendations
- Real-time schedule management

### 🍽️ Feeding Tracking & Notifications
- Mark multiple cats as fed instantly
- Track who fed them and portion sizes
- Smart push/email notifications for overdue feedings
- Escalation alerts for missed feedings
- Integration with Cloud Functions for automated reminders

### 📏 Weight Tracking
- Easy weight logging with timestamps and notes
- Weight history visualization
- Weight goals with progress tracking
- Optional reminder notifications
- Trend analysis and health insights

### 📊 Analytics & Dashboards
- Comprehensive feeding and weight logs
- Visual charts and trends (daily/weekly/monthly)
- Export data for vet visits
- Feeding frequency analysis
- Weight vs. intake correlations

### 🌍 Localization & Settings
- Multi-language support (English, Portuguese, Spanish)
- Timezone selection
- Theme customization (Light/Dark/System)
- Notification preferences

## Tech Stack

### Frontend
- **Flutter** - Cross-platform UI toolkit
- **Material Design 3 Expressive** - Modern, vibrant UI design
- **Provider** - State management
- **fl_chart** - Data visualization and analytics
- **flutter_localizations** - Multi-language support

### Backend & Services
- **Firebase Authentication** - User management and security
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Storage** - Cat photo storage
- **Firebase Cloud Messaging (FCM)** - Push notifications
- **Cloud Functions for Firebase** - Serverless backend logic

### Cloud Functions
- **Feeding Reminders** - Automated feeding notifications
- **Escalation Alerts** - Missed feeding alerts
- **Notification Management** - FCM integration

## Project Structure

```
lib/
├── models/           # Data models (User, Household, Cat, Feeding, WeightEntry)
├── services/         # Backend services (Auth, Database, Storage, Notifications)
├── screens/          # UI screens
├── widgets/          # Reusable UI components
├── providers/        # State management (Theme, Language, Household)
├── utils/            # Helpers, constants, validators
└── l10n/             # Localization files (en-US, pt-BR, es-ES)

functions/            # Cloud Functions (Node.js/TypeScript)
├── src/
│   ├── index.ts
│   ├── feedingReminders.ts
│   ├── escalationAlerts.ts
│   └── sendFeedingNotification.ts
├── package.json
└── tsconfig.json
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase CLI
- Node.js (18 or higher) for Cloud Functions
- Android Studio / Xcode for mobile development

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mealtime-flutter-firebase
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "mealtime"
3. Enable Authentication, Firestore, Storage, and Cloud Functions

#### Configure Authentication
1. Enable Email/Password authentication
2. Add your app to the project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories

#### Configure Firestore
1. Create Firestore database
2. Deploy security rules: `firebase deploy --only firestore:rules`
3. Deploy indexes: `firebase deploy --only firestore:indexes`

#### Configure Storage
1. Enable Cloud Storage
2. Deploy storage rules: `firebase deploy --only storage`

### 4. Cloud Functions Setup
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 5. Run the App
```bash
flutter run
```

## Security Rules

### Firestore Rules
- Users can only access their own data
- Household members can read/write household data
- Admins can modify household settings
- All data access is validated against household membership

### Storage Rules
- Cat photos restricted to household members
- 5MB file size limit
- Image format validation (jpg, jpeg, png, webp)
- User profile photos restricted to owner

## Localization

The app supports three languages:
- **English (en-US)** - Default
- **Portuguese (pt-BR)** - Brazilian Portuguese
- **Spanish (es-ES)** - European Spanish

Language files are located in `lib/l10n/` and use ARB format for easy translation management.

## Cloud Functions

### Feeding Reminders
- Runs every 15 minutes
- Checks all cats with active schedules
- Sends notifications for overdue feedings
- Triggers escalation alerts after 1 hour

### Escalation Alerts
- Handles missed feeding notifications
- Sends critical alerts after 3+ hours
- Logs escalation events for tracking

### Manual Notifications
- HTTP callable functions for manual notifications
- Weight reminder scheduling
- Custom notification sending

## Development

### Adding New Features
1. Create models in `lib/models/`
2. Add database methods in `lib/services/database_service.dart`
3. Create UI screens in `lib/screens/`
4. Add widgets in `lib/widgets/`
5. Update localization files if needed

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.