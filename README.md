# you_and_i

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Database connection

The application now expects database credentials to be provided via the `.env` file. Current production values are:

```
DB_HOST=218.145.31.95
DB_USER=youandi
DB_PASSWORD=uBpass4862!@
```

To connect manually (for example, to inspect data or run migrations), use your preferred MySQL-compatible client. A typical CLI connection looks like:

```bash
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD"
```

Update the `.env` file accordingly before launching the app so it can pick up the new database settings.
