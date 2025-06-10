import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login.dart';
import 'screens/todo_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://anlepviopbexlvvjktji.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubGVwdmlvcGJleGx2dmprdGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwNTMxMjgsImV4cCI6MjA2NDYyOTEyOH0.fYSNuls6bFtNua3nw7AU-esWC_QxcQSCVsDV_C26O1s',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TidyTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SessionCheckScreen(),
    );
  }
}

// ✅ แก้ให้เป็น StatefulWidget เพื่อเช็ค session ได้
class SessionCheckScreen extends StatefulWidget {
  const SessionCheckScreen({super.key});

  @override
  State<SessionCheckScreen> createState() => _SessionCheckScreenState();
}

class _SessionCheckScreenState extends State<SessionCheckScreen> {
  final supabase = Supabase.instance.client;
  bool _isChecking = true;
  bool _isLoggedIn = false;
  String _username = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      _username = user.userMetadata?['name'] ?? 'Google User';
      _userId = user.id;
      setState(() {
        _isLoggedIn = true;
        _isChecking = false;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn) {
      return ToDoListScreen(userId: _userId, username: _username);
    } else {
      return const LoginScreen();
    }
  }
}
