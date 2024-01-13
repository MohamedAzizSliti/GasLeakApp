import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("pngwing");

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Initialize FlutterLocalNotificationsPlugin
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('060606aziz', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    try {
      var details = await notificationDetails();
      await notificationsPlugin.show(id, title, body, details,
          payload: payLoad);
    } catch (e, stacktrace) {
      print('Error in showNotification function: $e $stacktrace');
      // You can also rethrow the exception if needed
      rethrow;
    }
  }
}
