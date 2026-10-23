# Local Task Manager — IT 126
## Reflection

### 1. Why does the application use SQLite instead of relying only on a Dart list?

The application uses SQLite to save tasks permanently on the device. A Dart list only stores tasks in memory while the application is running. SQLite allows saved tasks to remain available even after the application is closed and reopened.

### 2. What is the purpose of the primary key in the tasks table?

The `id` column serves as the primary key. It automatically generates a unique ID for every task, allowing the application to identify the correct task when updating its completion status or deleting it, even if two tasks have the same title.

### 3. How does the repository simplify the UI's interaction with the database?

The `TaskRepository` class organizes database operations in a separate file. The UI calls repository methods to add, retrieve, update, and delete tasks instead of executing database queries directly. This makes the code easier to understand, maintain, and manage.

### 4. What would happen if a task were removed from the displayed list but not deleted from SQLite?

The task would disappear from the screen temporarily, but its record would remain in the database. When the application reloads the saved tasks, the task would appear again. Therefore, the application must delete the record from SQLite before refreshing the displayed list.

### 5. If the database schema later needed a new column for task priority, what parts of the application might need to change?

The database table would need a new `priority` column, and the database version and migration logic might need to be updated. The `Task` model would need a priority property, and the repository would need to save and retrieve the priority value. The UI would also need a way to select and display each task's priority. These changes would allow the application to manage task priorities while preserving existing records.