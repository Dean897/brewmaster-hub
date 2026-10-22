import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  static const timerNotificationId = 1001;
  static const timerChannelId = 'brew_timer_alarm_spiderman';
  static const timerAlarmSound = RawResourceAndroidNotificationSound(
    'spiderman_meme_song',
  );

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } on Exception catch (error, stackTrace) {
      debugPrint('Gagal menentukan zona waktu notifikasi: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        timerChannelId,
        'Alarm Timer Seduh',
        description: 'Notifikasi saat timer seduh selesai',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: timerAlarmSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, sound: true);
  }

  Future<void> scheduleTimerCompletion(DateTime endTime) async {
    await _plugin.zonedSchedule(
      id: timerNotificationId,
      title: 'Timer Seduh Selesai',
      body:
          'Kopi Anda sudah siap. Tekan "Matikan Alarm" untuk menghentikan '
          'peringatan.',
      scheduledDate: tz.TZDateTime.from(endTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          timerChannelId,
          'Alarm Timer Seduh',
          channelDescription: 'Notifikasi saat timer seduh selesai',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: timerAlarmSound,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 800]),
          ongoing: true,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          actions: [
            AndroidNotificationAction(
              'stop_timer_alarm',
              'Matikan Alarm',
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTimerCompletion() {
    return _plugin.cancel(id: timerNotificationId);
  }
}
