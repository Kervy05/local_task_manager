import 'package:flutter/material.dart';

import 'database/task_repository.dart';
import 'models/task.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const LocalTaskManagerApp());
}

class LocalTaskManagerApp extends StatelessWidget {
  const LocalTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final _titleController = TextEditingController();
  final _repository = TaskRepository.instance;

  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAllTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load tasks. Please try again.');
    }
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a task title.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repository.createTask(title);
      if (!mounted) return;
      _titleController.clear();
      await _loadTasks();
      if (!mounted) return;
      _showMessage('Task added successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Task was not saved. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleTask(Task task, bool? checked) async {
    final newStatus = checked ?? false;
    try {
      final changedRows =
          await _repository.setTaskCompleted(task.id, newStatus);
      if (changedRows > 0) {
        await _loadTasks();
        if (mounted) {
          _showMessage(newStatus
              ? 'Task marked as completed.'
              : 'Task marked as pending.');
        }
      } else {
        _showMessage('No task was updated.');
      }
    } catch (error) {
      _showMessage('Could not update the task. Please try again.');
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final deletedRows = await _repository.deleteTask(task.id);
      if (deletedRows > 0) {
        await _loadTasks();
        if (mounted) _showMessage('Task deleted successfully.');
      } else {
        _showMessage('Task was not found and could not be deleted.');
      }
    } catch (error) {
      _showMessage('Could not delete the task. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Task Manager'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Your tasks stay saved on this device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _isSaving ? null : _addTask(),
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        hintText: 'Example: Finish IT 126 activity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _addTask,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_tasks.length} task(s) • $completedCount completed',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks yet.\nAdd your first task above!',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (value) =>
                                        _toggleTask(task, value),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: task.isCompleted
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    task.isCompleted ? 'Completed' : 'Pending',
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Delete task',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteTask(task),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
