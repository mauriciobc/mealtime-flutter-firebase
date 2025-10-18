
# MealTime App Blueprint

## Overview

MealTime is a Flutter application designed to help cat owners manage their pets' feeding schedules, monitor their weight, and track their health over time. The app utilizes Firebase for backend services, including user authentication, data storage, and push notifications.

## Key Features

*   **User Authentication:** Secure sign-up and login functionality using Firebase Authentication.
*   **Household Management:** Users can create or join households to manage multiple cats with other members of the family.
*   **Cat Profiles:** Create and manage profiles for each cat, including their name, photo, and feeding schedule.
*   **Feeding Schedule:** Set up customized feeding schedules for each cat, with options for regular intervals or specific times.
*   **Feeding History:** Log each feeding and view a history of all meals.
*   **Weight Tracking:** Record and monitor your cat's weight over time with visual charts.
*   **Push Notifications:** Receive reminders for feeding times.

## App Architecture

*   **State Management:** The app will use the `provider` package for state management, with `ChangeNotifier` to notify widgets of changes in the data.
*   **Firebase Integration:** Firebase will be used for:
    *   **Authentication:** `firebase_auth`
    *   **Database:** `cloud_firestore`
    *   **Storage:** `firebase_storage` for cat profile pictures
    *   **Push Notifications:** `firebase_messaging`
*   **Navigation:** The app will use `go_router` for declarative navigation, allowing for deep linking and a more organized routing structure.

## UI/UX Design

*   **Theme:** The app will feature a modern and clean design with a custom color scheme and typography using `google_fonts`. It will support both light and dark modes.
*   **Components:** Custom widgets will be created for UI elements like cat cards, feeding logs, and navigation to ensure a consistent look and feel.

## Error-Fixing Plan

The project currently has a number of analysis errors. The following steps will be taken to resolve them:

1.  **Fix `main.dart` Theming Errors:**
    *   Correct the `CardTheme` assignment to `CardThemeData`.
    *   Replace deprecated `surfaceVariant` with `surfaceContainerHighest`.
    *   Remove unused `secondarySeedColor` and `tertiarySeedColor` variables.

2.  **Resolve `add_cat_screen.dart` Issues:**
    *   Define the `ScheduleType` enum to fix the `undefined_identifier` error.
    *   Correct the `argument_type_not_assignable` error by converting the `File` to an `XFile` before passing it to the `ImagePicker`.

3.  **Address `analytics_screen.dart` Warnings:**
    *   Remove the unused import of `export_data_button.dart`.
    *   Replace the deprecated `withOpacity` with `.withValues()`.

4.  **Fix `cat_profile_screen.dart` Errors:**
    *   Add the necessary fields (`specificTimes`, `lastFed`) to the `FeedingSchedule` model.
    *   Define the `cat` variable to resolve the `undefined_identifier` errors.

5.  **Correct `cats_list_screen.dart` Warnings:**
    *   Replace the deprecated `withOpacity` with `.withValues()`.

6.  **Resolve `create_household_screen.dart` Warnings:**
    *   Fix the `use_build_context_synchronously` warnings by checking if the widget is mounted before using `BuildContext`.

7.  **Address `feed_cats_screen.dart` Issues:**
    *   Replace the deprecated `withOpacity` with `.withValues()`.
    *   Add the necessary fields to the `FeedingSchedule` model.

8.  **Fix `feeding_history_screen.dart` Warnings:**
    *   Replace the deprecated `withOpacity` with `.withValues()`.

9.  **Correct `household_selection_screen.dart` Warnings:**
    *   Replace the deprecated `withOpacity` with `.withValues()`.

10. **Resolve `household_settings_screen.dart` Errors:**
    *   Add the `removeHouseholdFromUser` method to the `DatabaseService`.
    *   Fix the `use_build_context_synchronously` warnings.
    *   Remove the unused `databaseService` variable.

11. **Address `join_household_screen.dart` Warnings:**
    *   Fix the `use_build_context_synchronously` warnings.

12. **Fix `login_screen.dart` Errors:**
    *   Correct the import paths for `auth_service.dart` and `signup_screen.dart`.
    *   Define the `AuthService` class and instantiate it correctly.

13. **Correct `settings_screen.dart` Issues:**
    *   Replace the deprecated `withOpacity`, `groupValue`, and `onChanged` with their modern equivalents.
    *   Fix the `argument_type_not_assignable` error by converting the `String` to a `Locale`.

14. **Resolve `signup_screen.dart` Errors:**
    *   Correct the import path for `auth_service.dart`.
    *   Define the `AuthService` class and instantiate it correctly.

15. **Address `weight_history_screen.dart` Issues:**
    *   Define the `WeightLogScreen` method.
    *   Replace the deprecated `withOpacity` with `.withValues()`.

16. **Fix `database_service.dart` Errors:**
    *   Correct the `argument_type_not_assignable` error by casting the `Object?` to a `Map<String, dynamic>`.

17. **Correct `notification_service.dart` Errors:**
    *   Add the `flutter_local_notifications` dependency to `pubspec.yaml`.
    *   Define the missing classes and methods.

18. **Resolve `widget_test.dart` Errors:**
    *   Correct the import path for `main.dart`.
    *   Define the `MyApp` class.

By following this plan, all analysis errors will be resolved, and the app will be in a runnable state.
