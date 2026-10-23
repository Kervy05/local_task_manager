# Reflection — Developing a Local Task Manager

**1. Why does the application use SQLite instead of relying only on a Dart list?**

The application uses SQLite because a Dart list only keeps the tasks in the running app's memory. If the app is terminated, that list is lost. SQLite saves each task in the device's local database file, so the app can load the tasks again when it is reopened. SQLite also provides structured operations for adding, reading, updating, and deleting records.

**2. What is the purpose of the primary key in the tasks table?**

The `id` column is the primary key. It is automatically generated and uniquely identifies each task, even when two tasks have the same title. The repository uses this ID in the update and delete operations so that only the selected task is changed or removed.

**3. How does the repository simplify the UI's interaction with the database?**

The `TaskRepository` puts database setup and CRUD operations in `lib/database/task_repository.dart`. The UI calls methods such as `createTask()`, `getAllTasks()`, `setTaskCompleted()`, and `deleteTask()` instead of writing SQL queries in the screen. This separates presentation from data access and makes the code easier to understand, maintain, and test.

**4. What would happen if a task were removed from the displayed list but not deleted from SQLite?**

The task would only disappear temporarily from the screen. Its record would still exist in SQLite, so it would appear again when the app reloads the tasks. In this implementation, the UI calls the repository's `deleteTask()` method and refreshes the list only after a successful database deletion.

**5. If the database schema later needed a new column for task priority, what parts of the application might need to change?**

The database schema would need a `priority` column, and the database version and upgrade/migration logic would need to be updated so existing installations can add the column safely. The `Task` model and its `fromMap()` conversion would need to represent priority. The repository's create and read methods would need to save and retrieve it, and the UI would need controls to choose and display the priority. Existing database records should receive a sensible default priority during migration.
