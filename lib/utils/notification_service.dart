import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // 通知頻道ID
  static const String _channelId = 'reminder_notifications';
  static const String _channelName = '提醒通知';
  static const String _channelDescription = '應用程式提醒通知';

  // 初始化通知服務
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化時區
    tz_data.initializeTimeZones();
    
    // 設定通知頻道
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // 檢查通知權限
  Future<bool> checkPermission() async {
    if (!_isInitialized) await initialize();
    
    final NotificationAppLaunchDetails? launchDetails = 
        await _notifications.getNotificationAppLaunchDetails();
    
    // 檢查Android權限
    bool permissionGranted = false;
    
    // 在Android 13+上檢查權限
    if (await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false) {
      permissionGranted = true;
    } else {
      // 請求權限
      permissionGranted = await requestPermission();
    }
    
    return permissionGranted;
  }

  // 請求通知權限
  Future<bool> requestPermission() async {
    if (!_isInitialized) await initialize();
    
    // 請求Android權限
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ?? false;
    }
    
    return true; // iOS在初始化時已請求權限
  }

  // 排程單次通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? soundName,
  }) async {
    if (!_isInitialized) await initialize();
    
    // 確保有通知權限
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('通知權限未授予，無法發送通知');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      sound: soundName != null 
          ? RawResourceAndroidNotificationSound(soundName)
          : const RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      fullScreenIntent: true, // 確保通知在鎖屏時也能顯示
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: soundName != null ? '$soundName.aiff' : 'notification_sound.aiff',
      badgeNumber: 1,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 確保在低功耗模式下也能觸發
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // 排程重複通知
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required RepeatInterval repeatInterval,
    String? payload,
    String? soundName,
  }) async {
    if (!_isInitialized) await initialize();
    
    // 確保有通知權限
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('通知權限未授予，無法發送通知');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      sound: soundName != null 
          ? RawResourceAndroidNotificationSound(soundName)
          : const RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: soundName != null ? '$soundName.aiff' : 'notification_sound.aiff',
      badgeNumber: 1,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _getNextInstanceTime(scheduledDate, repeatInterval),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: _getDateTimeComponents(repeatInterval),
    );
  }

  // 根據重複間隔獲取下一次通知時間
  tz.TZDateTime _getNextInstanceTime(DateTime scheduledDate, RepeatInterval interval) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    if (scheduledTZDate.isBefore(now)) {
      // 如果排程時間已過，根據重複間隔調整到下一個時間點
      switch (interval) {
        case RepeatInterval.hourly:
          scheduledTZDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            now.hour + 1,
            scheduledDate.minute,
            scheduledDate.second,
          );
          break;
        case RepeatInterval.daily:
          scheduledTZDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + 1,
            scheduledDate.hour,
            scheduledDate.minute,
            scheduledDate.second,
          );
          break;
        case RepeatInterval.weekly:
          scheduledTZDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + (7 - now.weekday + scheduledDate.weekday) % 7,
            scheduledDate.hour,
            scheduledDate.minute,
            scheduledDate.second,
          );
          break;
        default:
          scheduledTZDate = scheduledTZDate.add(const Duration(days: 1));
      }
    }
    
    return scheduledTZDate;
  }

  // 根據重複間隔獲取日期時間組件
  DateTimeComponents? _getDateTimeComponents(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return DateTimeComponents.time;
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      // RepeatInterval枚舉中沒有monthly和yearly值
      // 如果需要這些功能，可以使用其他方式實現
      // case RepeatInterval.monthly:
      //   return DateTimeComponents.dayOfMonthAndTime;
      // case RepeatInterval.yearly:
      //   return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  // 取消特定通知
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 獲取待處理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // 通知點擊事件處理
  void _onNotificationTapped(NotificationResponse response) {
    // 處理通知點擊事件
    print('通知被點擊: ${response.payload}');
    // 這裡可以添加導航到特定頁面的邏輯
  }
}