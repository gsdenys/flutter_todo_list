import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbHelper = DatabaseHelper();
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() => _tasks = tasks);
  }

  void _addTask() async {
    if (_controller.text.isEmpty) return;
    await _dbHelper.addTask(_controller.text);
    _controller.clear();
    _loadTasks();
  }

  void _toggleTaskCompletion(int id, int completed) async {
    await _dbHelper.updateTask(id, completed == 0 ? 1 : 0);
    _loadTasks();
  }

  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To-Do List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: "Enter Task"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task['title'],
                      style: TextStyle(
                          decoration: task['completed'] == 1
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                  trailing: Wrap(
                    children: [
                      Checkbox(
                        value: task['completed'] == 1,
                        onChanged: (_) => _toggleTaskCompletion(
                            task['id'], task['completed']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(task['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}