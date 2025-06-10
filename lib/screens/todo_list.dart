import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class ToDoListScreen extends StatefulWidget {
  final String? userId;
  final String? username;

  const ToDoListScreen({super.key, this.userId, this.username});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController taskController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = supabase.auth.currentUser;

    if (currentUser == null && widget.userId == null) {
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      });
    } else {
      fetchTasks();
    }
  }

  Future<void> fetchTasks() async {
    final userId = widget.userId ?? currentUser?.id;
    if (userId == null) return;

    final data = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    setState(() {
      tasks = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> addTask(String title) async {
    final userId = widget.userId ?? currentUser?.id;
    if (title.trim().isEmpty || userId == null) return;

    await supabase.from('tasks').insert({'user_id': userId, 'title': title});

    taskController.clear();
    fetchTasks();
  }

  Future<void> toggleDone(String taskId, bool current) async {
    await supabase.from('tasks').update({'is_done': !current}).eq('id', taskId);
    fetchTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await supabase.from('tasks').delete().eq('id', taskId);
    fetchTasks();
  }

  void logout() async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.username ??
        currentUser?.userMetadata?['name'] ??
        currentUser?.email ??
        'User';

    return Scaffold(
      backgroundColor: Color(0xFF1C1F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Tidy',
                style: TextStyle(
                  fontSize: 28,
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
            RichText(
              text: TextSpan(
                text: 'Welcome, ',
                style: TextStyle(fontSize: 14, color: Colors.white),
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...tasks.map((task) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D32),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: GestureDetector(
                    onTap: () => toggleDone(task['id'], task['is_done']),
                    child: Text(
                      task['title'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        decoration: task['is_done']
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: task['is_done']
                            ? Colors.red
                            : Colors.transparent,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => deleteTask(task['id']),
                  ),
                ),
              );
            }),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add Task',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.red),
                    onPressed: () => addTask(taskController.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
