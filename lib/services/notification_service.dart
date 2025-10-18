import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _initializeLocalNotifications();
      await requestPermissions();
      await _configureFCM();
      _initialized = true;
      developer.log('NotificationService initialized successfully');
    } catch (e) {
      developer.log('Error initializing NotificationService: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _configureFCM() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final fcmSettings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (fcmSettings.authorizationStatus == AuthorizationStatus.authorized) {
        return true;
      }

      return false;
    } catch (e) {
      developer.log('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> subscribeToHousehold(String householdId) async {
    try {
      await _firebaseMessaging.subscribeToTopic('household_$householdId');
      developer.log('Subscribed to household notifications: $householdId');
    } catch (e) {
      developer.log('Error subscribing to household: $e');
    }
  }

  Future<void> unsubscribeFromHousehold(String householdId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('household_$householdId');
      developer.log('Unsubscribed from household notifications: $householdId');
    } catch (e) {
      developer.log('Error unsubscribing from household: $e');
    }
  }

  Future<void> scheduleFeedingReminder({
    required String catId,
    required String catName,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        catId.hashCode,
        'Hora da alimentação! 🐱',
        '$catName precisa ser alimentado${notes != null ? ': $notes' : ''}',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'feeding_reminders',
            'Lembretes de Alimentação',
            channelDescription:
                'Notificações para lembrar de alimentar os gatos',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      developer.log(
        'Scheduled feeding reminder for $catName at $scheduledTime',
      );
    } catch (e) {
      developer.log('Error scheduling feeding reminder: $e');
    }
  }

  Future<void> scheduleWeightReminder({
    required String catId,
    required String catName,
    required String frequency, // 'daily', 'weekly', 'monthly'
  }) async {
    try {
      DateTime scheduledTime;
      final now = DateTime.now();

      switch (frequency) {
        case 'daily':
          scheduledTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
          break;
        case 'weekly':
          scheduledTime = DateTime(now.year, now.month, now.day + 7, 9, 0);
          break;
        case 'monthly':
          scheduledTime = DateTime(now.year, now.month + 1, now.day, 9, 0);
          break;
        default:
          return;
      }

      await _localNotifications.zonedSchedule(
        '${catId}_weight'.hashCode,
        'Lembrete de pesagem 📏',
        'Hora de pesar $catName',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weight_reminders',
            'Lembretes de Peso',
            channelDescription: 'Notificações para lembrar de pesar os gatos',
            importance: Importance.max,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      developer.log('Scheduled weight reminder for $catName ($frequency)');
    } catch (e) {
      developer.log('Error scheduling weight reminder: $e');
    }
  }

  Future<void> cancelFeedingReminder(String catId) async {
    try {
      await _localNotifications.cancel(catId.hashCode);
      developer.log('Cancelled feeding reminder for cat: $catId');
    } catch (e) {
      developer.log('Error cancelling feeding reminder: $e');
    }
  }

  Future<void> cancelWeightReminder(String catId) async {
    try {
      await _localNotifications.cancel('${catId}_weight'.hashCode);
      developer.log('Cancelled weight reminder for cat: $catId');
    } catch (e) {
      developer.log('Error cancelling weight reminder: $e');
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate',
            'Notificações Imediatas',
            channelDescription: 'Notificações instantâneas do app',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      developer.log('Error showing immediate notification: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    developer.log('Received foreground message: ${message.messageId}');

    if (message.notification != null) {
      showImmediateNotification(
        title: message.notification!.title ?? 'MealTime',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification tapped: ${message.messageId}');

    final data = message.data;
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'feeding_reminder':
          _handleFeedingReminderTap(data);
          break;
        case 'weight_reminder':
          _handleWeightReminderTap(data);
          break;
        case 'escalation_alert':
          _handleEscalationAlertTap(data);
          break;
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  void _handleFeedingReminderTap(Map<String, dynamic> data) {
    final catId = data['catId'];
    final householdId = data['householdId'];

    if (catId != null && householdId != null) {
      developer.log('Navigate to feeding screen for cat: $catId');
    }
  }

  void _handleWeightReminderTap(Map<String, dynamic> data) {
    final catId = data['catId'];

    if (catId != null) {
      developer.log('Navigate to weight logging screen for cat: $catId');
    }
  }

  void _handleEscalationAlertTap(Map<String, dynamic> data) {
    final householdId = data['householdId'];
    final catId = data['catId'];

    if (householdId != null) {
      developer.log(
        'Navigate to escalation alert for household: $householdId, cat: $catId',
      );
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      developer.log('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      developer.log('Cleared all notifications');
    } catch (e) {
      developer.log('Error clearing notifications: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling background message: ${message.messageId}');
}
