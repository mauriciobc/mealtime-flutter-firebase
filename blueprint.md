# MealTime App Blueprint

## 1. Overview

MealTime is a smart household management app designed to streamline cat feeding routines, ensuring pets are fed consistently and responsibly. The app enables collaborative care among household members, offering configurable feeding schedules, real-time tracking, weight monitoring, and comprehensive analytics to promote feline health and household coordination.

## 2. Features

### Household & User Management
*   **Create/Join Households**: Users can register a new household or join an existing one via an invite link. This will centralize the management of cats and caregivers.
*   **Role-Based Access**: Assign roles (Admin, Member) to control permissions for editing schedules or managing pets.
*   **Multi-User Sync**: Real-time updates to ensure all members are aligned on feeding tasks, logs, and weight entries.

### Cat Profile Management
*   **Detailed Profiles**: Create profiles for each cat including name, photo, birthdate, current weight, dietary restrictions, and medical notes.
*   **Grouping**: Organize cats into groups (e.g., kittens, seniors) for bulk actions.

### Feeding Interval Configuration
*   **Custom Schedules**: Set fixed intervals (e.g., every 4 hours) or specific times (e.g., 8 AM, 6 PM). Schedules can be applied to individual cats or groups.
*   **Override Options**: Temporarily adjust schedules for holidays or vet-recommended changes.

### Feeding Tracking & Notifications
*   **Mark as Fed**: Log feedings for one or multiple cats instantly, tracking who fed them and the portion size.
*   **Smart Alerts**: Push/email notifications will be triggered when feeding intervals lapse. Escalation alerts can notify other members if a task is missed.

### Weight Tracking
*   **Weight Logging**: Easily log a cat's weight with a timestamp and optional notes.
*   **Weight History**: View a dedicated log of all weight entries for each cat.
*   **Weight Goals (Optional)**: Set a target weight range (lose, maintain, gain) for a cat, with visual indicators to track progress.
*   **Reminder Notifications**: Set optional reminders for weekly weigh-ins.

### Feeding & Weight Analytics
*   **Comprehensive Logs**: View timestamped feeding and weight history for each cat.
*   **Insightful Dashboards**: Visualize trends with charts (daily/weekly feeding frequency, weight over time, weight vs. intake) and export data.

### App Settings
*   **Timezone Selection**: User-defined timezone options.
*   **Language and Localization**: Support for en-US, pt-BR, es-ES.

## 3. Tech Stack

*   **Mobile App (Frontend)**: Flutter
*   **Backend & Core Services**: Google Firebase
    *   **Database**: Cloud Firestore
    *   **Authentication**: Firebase Authentication
    *   **Serverless Logic**: Cloud Functions for Firebase
    *   **Push Notifications**: Firebase Cloud Messaging (FCM)
    *   **File Storage**: Firebase Cloud Storage
*   **Analytics & Visualization**: `fl_chart` Flutter Package
*   **Localization**: `intl` Flutter Package

## 4. Architecture

The application will follow a feature-first layered architecture:

*   **`lib/src/features`**: Each feature will have its own directory containing subdirectories for `data`, `domain`, `presentation`.
    *   **`data`**: Repositories and data sources (e.g., Firestore services).
    *   **`domain`**: Models and business logic.
    *   **`presentation`**: UI (widgets, screens, and state management).
*   **`lib/src/core`**: Shared utilities, constants, and theme data.
*   **`lib/src/app`**: The main application widget and routing configuration.

**State Management**: We will use the `provider` package for state management, following the `ChangeNotifier` pattern.

## 5. Initial Plan

1.  **Project Setup**:
    *   Create the feature-first directory structure.
    *   Add necessary dependencies to `pubspec.yaml` (`provider`, `fl_chart`, `intl`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`).
2.  **Firebase Integration**:
    *   Configure Firebase for the Flutter project.
3.  **Authentication Feature**:
    *   Implement the UI for user registration and login.
    *   Create the authentication service to interact with Firebase Auth.
4.  **Household Feature**:
    *   Implement the UI for creating and joining households.
    *   Create the data models and Firestore service for households.
5.  **Cat Profile Feature**:
    *   Implement the UI for creating and managing cat profiles.
    *   Create the data models and Firestore service for cat profiles.
