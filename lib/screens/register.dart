import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showError('Please fill in all fields');
      return;
    }

    try {
      // ✅ 1. Register with Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        showError('Register failed: No user returned');
        return;
      }

      // ✅ 2. Check if profile already exists (Optional Safety)
      final exists = await supabase
          .from('tidytasks')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (exists == null) {
        // ✅ 3. Insert profile to tidytasks
        await supabase.from('tidytasks').insert({
          'id': user.id,
          'username': username,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Register success! Please login')),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      showError(e.message);
    } catch (e) {
      showError('Unexpected error: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('❌ $message')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color(0xFF1C1F23),
    appBar: AppBar(
      title: Text('Register'),
      backgroundColor: Colors.transparent,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Tidy',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              children: [
                TextSpan(
                  text: 'Tasks',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: ' Register',
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Username
          TextField(
            controller: usernameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Email
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

          // Password
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
          SizedBox(height: 24),

          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Register',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Login >',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
