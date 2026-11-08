import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services & Models Imports
import 'core/services/notification_service.dart';
import 'viewmodels/diary_viewmodel.dart';

// Views Imports
import 'views/auth/lock_screen.dart';

void main() async {
  // Flutter Widgets Binding Initialize කිරීම
  WidgetsFlutterBinding.ensureInitialized();
  
  // Notification System එක Initialize කිරීම
  await NotificationService.initNotification();

  // 1. Instant Test Notification (App එක Open වෙද්දී සැනින් Notification එකක් එනවාද බැලීමට)
  // (මෙය පරීක්ෂා කර බැලීමෙන් පසු අයින් කර දැමිය හැක)
  await NotificationService.showTestNotification();

  // 2. පරිශීලකයා SharedPreferences වල Save කර ඇති Reminder Time එක ලබාගෙන Auto-Schedule කිරීම
  final savedTime = await NotificationService.getSavedNotificationTime();
  await NotificationService.scheduleDailyNotification(
    hour: savedTime.hour,
    minute: savedTime.minute,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryViewModel()),
      ],
      child: const DailyDiaryApp(),
    ),
  );
}

class DailyDiaryApp extends StatelessWidget {
  const DailyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      // App එක ආරම්භයේදීම Security Lock Screen එකට යොමු කෙරේ
      home: const LockScreen(),
    );
  }
}