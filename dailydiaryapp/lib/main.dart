import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/diary_viewmodel.dart';
import 'views/home/home_screen.dart';
import 'views/auth/lock_screen.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LockScreen(), // <--- LockScreen එක මෙතැනට දෙන්න
    );
  }
}