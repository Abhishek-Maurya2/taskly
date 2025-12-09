# Taskly

Local-first task manager for Android, Web, and Windows. Inspired by Google Tasks with lists, subtasks, attachments, reminders, swipe/long-press actions, and a settings surface ready for future Supabase sync.

## Features
- Task lists with star/selection chips, FAB, circular checkboxes, swipe-to-delete, long-press quick actions, haptic feedback.
- Tasks with description, subtasks, attachments (file picker), deadlines and reminder timestamps, starred and completed states.
- Local-first persistence via `shared_preferences`; notification scheduling via `flutter_local_notifications` (UI + scheduling where supported).
- Settings page to clear notifications and tweak list star preference; modular structure for future Supabase integration.

## Project Structure
- `lib/src/models` – task, list, attachment, subtask models.
- `lib/src/data` – repository abstraction and local implementation.
- `lib/src/state` – `TaskStore` ChangeNotifier for CRUD/state.
- `lib/src/widgets` – task tiles and editor sheet.
- `lib/src/screens` – home shell and settings page.
- `lib/src/services` – notification service.

## Run
```bash
flutter pub get
flutter run -d chrome   # web
flutter run -d windows  # windows desktop
flutter run -d android  # android device/emulator
```

## Notes
- Notifications require platform support/permissions; on web they are UI only.
- Supabase sync is planned; current build is fully local.
