# MealTime App Blueprint

## Overview

MealTime is a comprehensive Flutter application designed to streamline cat feeding routines and household pet management. The app enables collaborative care among household members, offering configurable feeding schedules, real-time tracking, weight monitoring, and comprehensive analytics to promote feline health and household coordination.

## Architecture

### Frontend (Flutter)
- **Framework:** Flutter 3.9.0+ with Dart
- **State Management:** Provider pattern for reactive state
- **UI Design:** Material Design 3 Expressive with vibrant colors
- **Navigation:** Bottom navigation with 4 main tabs
- **Localization:** Multi-language support (en-US, pt-BR, es-ES)

### Backend (Firebase)
- **Authentication:** Firebase Auth with email/password
- **Database:** Cloud Firestore for real-time data sync
- **Storage:** Firebase Storage for cat photos
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Functions:** Cloud Functions for automated reminders and alerts

### Data Flow
```
User Input → Flutter UI → Provider State → Database Service → Firestore
                ↓
Cloud Functions ← Firestore Triggers ← Scheduled Functions
                ↓
FCM → Push Notifications → User Device
```

## Core Features

### 1. Household & User Management
- **Multi-tenant Architecture:** Users can belong to multiple households
- **Role-based Access:** Admin and Member roles with different permissions
- **Invite System:** 6-character invite codes for household joining
- **Real-time Sync:** All members see updates instantly

### 2. Cat Profile Management
- **Comprehensive Profiles:** Name, photo, birthdate, weight, medical notes
- **Photo Management:** Optional upload with placeholder fallback
- **Grouping System:** Organize cats into groups (kittens, seniors, etc.)
- **Health Tracking:** Dietary restrictions and medical notes

### 3. Feeding Schedule System
- **Flexible Scheduling:** Fixed intervals or specific times
- **Bulk Operations:** Apply schedules to multiple cats
- **Override Capability:** Temporary schedule changes
- **Real-time Updates:** Schedule changes sync across all devices

### 4. Feeding Tracking & Notifications
- **Multi-cat Feeding:** Select and feed multiple cats simultaneously
- **Detailed Logging:** Track who fed, portion size, food type, notes
- **Smart Notifications:** Automated reminders based on schedules
- **Escalation System:** Alerts for missed feedings with increasing urgency

### 5. Weight Tracking System
- **Easy Logging:** Quick weight entry with optional notes
- **Goal Setting:** Target weight with progress tracking
- **Trend Analysis:** Visual charts showing weight changes over time
- **Health Insights:** Correlations between feeding and weight

### 6. Analytics & Dashboards
- **Feeding Analytics:** Frequency, timing, and success rates
- **Weight Trends:** Historical data with trend analysis
- **Export Functionality:** Data export for veterinary visits
- **Visual Charts:** Interactive graphs using fl_chart

## Data Models

### User Model
```dart
class UserModel {
  String uid;
  String email;
  String displayName;
  String? photoUrl;
  List<String> householdIds;
  String preferredLanguage;
  String timezone;
  DateTime createdAt;
  DateTime lastActiveAt;
}
```

### Household Model
```dart
class Household {
  String id;
  String name;
  String createdBy;
  DateTime createdAt;
  String? inviteCode;
  List<HouseholdMember> members;
  String? description;
}
```

### Cat Model
```dart
class Cat {
  String id;
  String householdId;
  String name;
  String? photoUrl;
  DateTime? birthdate;
  double? currentWeight;
  String? dietaryRestrictions;
  String? medicalNotes;
  List<String>? groups;
  FeedingSchedule schedule;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Feeding Model
```dart
class Feeding {
  String id;
  String catId;
  String householdId;
  String fedBy;
  DateTime timestamp;
  double? portionSize;
  String? notes;
  String? foodType;
  bool wasEaten;
}
```

### Weight Entry Model
```dart
class WeightEntry {
  String id;
  String catId;
  double weight;
  DateTime timestamp;
  String loggedBy;
  String? notes;
  String? measurementType;
}
```

## Database Structure (Firestore)

### Collections
- **users:** User profiles and preferences
- **households:** Household data and member lists
- **cats:** Cat profiles and schedules
- **feedings:** Feeding logs and history
- **weight_entries:** Weight tracking data
- **weight_goals:** Weight goals and targets
- **escalation_logs:** Missed feeding alerts
- **notification_logs:** Notification history

### Security Rules
- **User Data:** Only accessible by the user
- **Household Data:** Accessible by household members
- **Cat Data:** Accessible by household members
- **Feeding Data:** Accessible by household members
- **Weight Data:** Accessible by household members

## Cloud Functions

### Scheduled Functions
- **checkFeedingReminders:** Runs every 15 minutes
- **cleanupEscalationLogs:** Runs daily to clean old logs

### Triggered Functions
- **handleEscalationAlerts:** Processes escalation events
- **sendFeedingNotification:** Manual notification sending
- **sendWeightReminder:** Weight reminder scheduling

## UI/UX Design

### Material Design 3 Expressive
- **Color Palette:** Vibrant purple primary (#6750A4), warm pink tertiary (#7D5260)
- **Typography:** Inter font family with proper weight hierarchy
- **Components:** Rounded corners (20px), elevated cards, expressive buttons
- **Animations:** Smooth transitions and micro-interactions

### Navigation Structure
1. **Home Tab:** Cat list with next feeding times
2. **Feed Tab:** Quick feeding interface
3. **Analytics Tab:** Charts and insights
4. **Settings Tab:** User preferences and household management

### Responsive Design
- **Mobile-first:** Optimized for smartphones
- **Tablet Support:** Adaptive layouts for larger screens
- **Accessibility:** Screen reader support and high contrast

## Localization Strategy

### Supported Languages
- **English (en-US):** Primary language
- **Portuguese (pt-BR):** Brazilian Portuguese
- **Spanish (es-ES):** European Spanish

### Implementation
- **ARB Files:** Flutter's standard localization format
- **Dynamic Loading:** Language switching without app restart
- **Context-aware:** Proper pluralization and date formatting

## Security Considerations

### Data Protection
- **Encryption:** All data encrypted in transit and at rest
- **Access Control:** Role-based permissions
- **Input Validation:** Client and server-side validation
- **Audit Logging:** Track all data modifications

### Privacy
- **Minimal Data Collection:** Only necessary information
- **User Control:** Users can delete their data
- **GDPR Compliance:** European data protection standards

## Performance Optimization

### Frontend
- **Lazy Loading:** Load data as needed
- **Caching:** Local storage for frequently accessed data
- **Image Optimization:** Compressed photos with proper sizing
- **State Management:** Efficient provider updates

### Backend
- **Database Indexing:** Optimized queries
- **Cloud Functions:** Serverless scaling
- **CDN:** Fast image delivery
- **Caching:** Reduced database reads

## Testing Strategy

### Unit Tests
- **Models:** Data validation and serialization
- **Services:** Business logic and API calls
- **Providers:** State management logic

### Widget Tests
- **UI Components:** Individual widget behavior
- **User Interactions:** Tap, scroll, form input
- **State Changes:** Provider updates

### Integration Tests
- **User Flows:** Complete user journeys
- **Firebase Integration:** Real database operations
- **Cross-platform:** iOS and Android compatibility

## Deployment

### Development
- **Firebase Emulators:** Local development environment
- **Hot Reload:** Fast development iteration
- **Debug Tools:** Comprehensive logging and debugging

### Production
- **Firebase Hosting:** Web app deployment
- **App Stores:** iOS App Store and Google Play Store
- **Cloud Functions:** Automatic scaling and deployment
- **Monitoring:** Firebase Analytics and Crashlytics

## Future Enhancements

### Planned Features
- **Veterinary Integration:** Direct vet communication
- **Health Records:** Medical history tracking
- **Social Features:** Share cat photos and achievements
- **AI Insights:** Machine learning for health predictions
- **IoT Integration:** Smart feeder connectivity

### Scalability
- **Multi-pet Support:** Dogs, birds, other pets
- **Enterprise Features:** Veterinary clinic management
- **API Access:** Third-party integrations
- **Advanced Analytics:** Machine learning insights

## Maintenance

### Regular Tasks
- **Dependency Updates:** Keep packages current
- **Security Patches:** Regular security updates
- **Performance Monitoring:** Track app performance
- **User Feedback:** Continuous improvement based on feedback

### Monitoring
- **Crash Reporting:** Firebase Crashlytics
- **Analytics:** User behavior and app usage
- **Performance:** App speed and responsiveness
- **Errors:** Real-time error tracking
