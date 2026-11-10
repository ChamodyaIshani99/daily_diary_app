import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services & Models Imports
import 'core/services/notification_service.dart';
import 'viewmodels/diary_viewmodel.dart';

// Views Imports
import 'views/auth/lock_screen.dart';
import 'views/splash/loading_screen.dart'; // Loading screen imported

void main() async {
  // Flutter widgets binding initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Notification system initialized
  await NotificationService.initNotification();

  // Note: The test notification has been removed for now (notifications are no longer triggered every time the app is opened).
  // This is only needed if you want to add a button in Settings and call it manually.

  // Retrieve the reminder time saved by the user in SharedPreferences and auto-schedule it
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
      // The app shows the loading screen immediately at startup
      home: const InitialWrapper(),
    );
  }
}

// Initial Wrapper: Shows the loading screen for a few seconds before moving to the lock screen
class InitialWrapper extends StatefulWidget {
  const InitialWrapper({super.key});

  @override
  State<InitialWrapper> createState() => _InitialWrapperState();
}

class _InitialWrapperState extends State<InitialWrapper> {
  @override
  void initState() {
    super.initState();
    // Show the loading screen for 2.5 seconds before switching to the lock screen
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LockScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // The previously created loading screen is displayed here (to avoid the logo clipping issue)
    return const LoadingScreen();
  }
}