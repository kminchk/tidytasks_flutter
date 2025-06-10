import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register.dart';
import 'todo_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Login failed')));
        return;
      }

      // ✅ เช็กว่าอีเมลยืนยันแล้วหรือยัง
      if (user.confirmedAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📩 Please confirm your email before logging in.'),
          ),
        );
        return;
      }

      // ✅ ดึงชื่อผู้ใช้จากตาราง tidytasks
      final profile = await supabase
          .from('tidytasks')
          .select('username')
          .eq('id', user.id)
          .single();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Login success!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ToDoListScreen(userId: user.id, username: profile['username']),
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Unexpected error: $e')));
    }
  }

  void loginWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      showError('Google Sign-In Error: $e');
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('❌ $msg')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color(0xFF1C1F23),
    appBar: AppBar(title: Text(''), backgroundColor: Colors.transparent),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Tidy',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              children: [
                TextSpan(
                  text: 'Tasks',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          TextField(
            controller: emailController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(3),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loginUser,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent, width: 2),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: loginWithGoogle,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/google_icon.png', height: 24),
                  SizedBox(width: 10),
                  Text(
                    'Login with Google',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterScreen()),
            ),
            child: Text(
              'Register here',
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Please enter your email first')),
                );
                return;
              }
              try {
                await supabase.auth.resetPasswordForEmail(
                  email,
                  redirectTo: 'io.supabase.flutter://login-callback/',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📧 Password reset email sent')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
              }
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    ),
  );
}
