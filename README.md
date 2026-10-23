# Local Task Manager — IT 126

A simple one-screen Flutter application using SQLite (`sqflite`) and a repository.

## Requirements
- Flutter SDK installed
- Android Studio or VS Code with Flutter/Dart extensions
- Android emulator or Android device for running the SQLite app

## Run the project
1. Extract this ZIP file.
2. Open the `local_task_manager` folder in VS Code.
3. Open the terminal in that folder.
4. Run:
   ```bash
   flutter pub get
   flutter run
   ```

If you are starting from a newly created Flutter project instead, create it with
`flutter create local_task_manager`, then replace its `pubspec.yaml` and `lib`
files with the files in this package.

## Files
- `lib/main.dart` — user interface, input validation, loading, feedback, and refreshing.
- `lib/models/task.dart` — converts a database row into a Task object.
- `lib/database/task_repository.dart` — creates the database and performs Create, Read, Update, and Delete operations.
- `pubspec.yaml` — dependencies, including `sqflite` and `path`.

## Database
The database is stored locally as `tasks.db`. The `tasks` table contains:
- `id`: auto-incrementing primary key
- `title`: task title
- `is_completed`: `0` for pending and `1` for completed

## Test persistence
1. Add a task.
2. Close/stop the app, then launch it again.
3. Confirm the task is still displayed.
4. Mark it completed and confirm its status remains after restarting.
5. Delete a task and confirm it does not return after restarting.

The database is local to the device/emulator. Uninstalling the app may remove its local database.
