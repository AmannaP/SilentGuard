import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  String? _lastMessageId;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void startListeningForMessages(String currentUserId) {
    if (_chatSubscription != null) return;
    
    final participants = [currentUserId, 'renel_ghana_default'];
    participants.sort();
    final chatRoomId = participants.join('_');

    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        
        if (_lastMessageId == null) {
           _lastMessageId = doc.id;
           return; // Ignore the initial load
        }
        
        if (doc.id != _lastMessageId) {
           _lastMessageId = doc.id;
           if (data['senderId'] != currentUserId) {
             showNotification(
               id: DateTime.now().millisecond,
               title: 'Renel Ghana',
               body: data['text'] != null && data['text'].toString().isNotEmpty 
                   ? data['text'].toString() 
                   : 'Sent an attachment',
             );
           }
        }
      }
    });
  }

  void stopListening() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    _lastMessageId = null;
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'silentguard_messages',
      'Messages',
      channelDescription: 'Notifications for incoming messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
