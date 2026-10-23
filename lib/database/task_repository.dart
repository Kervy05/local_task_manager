import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';

class TaskRepository {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

final databasePath = kIsWeb
    ? 'tasks_web.db'
    : p.join(await getDatabasesPath(), 'tasks.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> createTask(String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    final db = await database;
    return db.insert('tasks', {
      'title': cleanTitle,
      'is_completed': 0,
    });
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'id DESC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> setTaskCompleted(int id, bool isCompleted) async {
    final db = await database;
    return db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
