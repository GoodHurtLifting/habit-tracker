import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/weekly_summary.dart';
import '../utils/habit_color_utils.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String _databaseName = 'habit_tracker.db';
  static const int _databaseVersion = 9;

  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';
  static const String weeklySummariesTable = 'weekly_summaries';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $habitsTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            type TEXT NOT NULL,
            created_at TEXT NOT NULL,
            milestone_track_id TEXT,
            is_paused INTEGER NOT NULL DEFAULT 0,
            paused_at TEXT,
            resumed_at TEXT,
            is_archived INTEGER NOT NULL DEFAULT 0,
            archived_at TEXT,
            sort_order INTEGER NOT NULL,
            accent_color_key TEXT NOT NULL,
            trigger1 TEXT,
            trigger2 TEXT,
            trigger3 TEXT,
            motivation1 TEXT,
            motivation2 TEXT,
            motivation3 TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $habitLogsTable (
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY (habit_id) REFERENCES $habitsTable(id) ON DELETE CASCADE
          )
        ''');

        await _createWeeklySummariesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final List<Map<String, Object?>> columns =
              await db.rawQuery('PRAGMA table_info($habitsTable)');

          final bool hasMilestoneTrackId = columns.any(
            (column) => column['name'] == 'milestone_track_id',
          );

          if (!hasMilestoneTrackId) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN milestone_track_id TEXT',
            );
          }
        }

        if (oldVersion < 3) {
          await _createWeeklySummariesTable(db);
        }

        if (oldVersion < 4) {
          final List<Map<String, Object?>> columns =
              await db.rawQuery('PRAGMA table_info($habitsTable)');

          final bool hasIsPaused = columns.any(
            (column) => column['name'] == 'is_paused',
          );
          final bool hasPausedAt = columns.any(
            (column) => column['name'] == 'paused_at',
          );
          final bool hasResumedAt = columns.any(
            (column) => column['name'] == 'resumed_at',
          );

          if (!hasIsPaused) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN is_paused INTEGER NOT NULL DEFAULT 0',
            );
          }

          if (!hasPausedAt) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN paused_at TEXT',
            );
          }

          if (!hasResumedAt) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN resumed_at TEXT',
            );
          }
        }

        if (oldVersion < 5) {
          final List<Map<String, Object?>> columns =
              await db.rawQuery('PRAGMA table_info($habitsTable)');

          final bool hasIsArchived = columns.any(
            (column) => column['name'] == 'is_archived',
          );
          final bool hasArchivedAt = columns.any(
            (column) => column['name'] == 'archived_at',
          );

          if (!hasIsArchived) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0',
            );
          }

          if (!hasArchivedAt) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN archived_at TEXT',
            );
          }
        }

        if (oldVersion < 6) {
          final List<Map<String, Object?>> columns =
              await db.rawQuery('PRAGMA table_info($habitsTable)');

          final bool hasSortOrder = columns.any(
            (column) => column['name'] == 'sort_order',
          );

          if (!hasSortOrder) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0',
            );

            final List<Map<String, Object?>> habitRows = await db.query(
              habitsTable,
              columns: ['id'],
              orderBy: 'created_at ASC',
            );

            await db.transaction((txn) async {
              for (int i = 0; i < habitRows.length; i++) {
                await txn.update(
                  habitsTable,
                  {'sort_order': i},
                  where: 'id = ?',
                  whereArgs: [habitRows[i]['id']],
                );
              }
            });
          }
        }

        if (oldVersion < 7) {
          await _ensureAccentColorColumnAndBackfill(db);
        }

        if (oldVersion < 8) {
          final List<Map<String, Object?>> columns =
              await db.rawQuery('PRAGMA table_info($habitsTable)');

          final bool hasTrigger1 = columns.any(
            (column) => column['name'] == 'trigger1',
          );
          final bool hasTrigger2 = columns.any(
            (column) => column['name'] == 'trigger2',
          );
          final bool hasTrigger3 = columns.any(
            (column) => column['name'] == 'trigger3',
          );
          final bool hasMotivation1 = columns.any(
            (column) => column['name'] == 'motivation1',
          );
          final bool hasMotivation2 = columns.any(
            (column) => column['name'] == 'motivation2',
          );
          final bool hasMotivation3 = columns.any(
            (column) => column['name'] == 'motivation3',
          );

          if (!hasTrigger1) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN trigger1 TEXT',
            );
          }
          if (!hasTrigger2) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN trigger2 TEXT',
            );
          }
          if (!hasTrigger3) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN trigger3 TEXT',
            );
          }
          if (!hasMotivation1) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN motivation1 TEXT',
            );
          }
          if (!hasMotivation2) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN motivation2 TEXT',
            );
          }
          if (!hasMotivation3) {
            await db.execute(
              'ALTER TABLE $habitsTable ADD COLUMN motivation3 TEXT',
            );
          }
        }

        if (oldVersion < 9) {
          await _deleteOrphanHabitLogs(db);
        }
      },
    );
  }

  Future<void> _deleteOrphanHabitLogs(Database db) async {
    await db.delete(
      habitLogsTable,
      where: 'habit_id NOT IN (SELECT id FROM $habitsTable)',
    );
  }

  Future<void> _ensureAccentColorColumnAndBackfill(Database db) async {
    final List<Map<String, Object?>> columns =
        await db.rawQuery('PRAGMA table_info($habitsTable)');
    final bool hasAccentColorKey = columns.any(
      (column) => column['name'] == 'accent_color_key',
    );

    if (!hasAccentColorKey) {
      await db.execute(
        'ALTER TABLE $habitsTable ADD COLUMN accent_color_key TEXT',
      );
    }

    final List<Map<String, Object?>> habitRows = await db.query(
      habitsTable,
      columns: ['id', 'type', 'accent_color_key'],
      orderBy: 'created_at ASC, id ASC',
    );

    int buildIndex = 0;
    int avoidIndex = 0;

    await db.transaction((txn) async {
      for (final row in habitRows) {
        final String? existingKey = row['accent_color_key'] as String?;
        if (existingKey != null && existingKey.trim().isNotEmpty) {
          continue;
        }

        final HabitType type = row['type'] == HabitType.avoid.name
            ? HabitType.avoid
            : HabitType.build;
        final int index = type == HabitType.avoid ? avoidIndex++ : buildIndex++;
        final String accentColorKey =
            HabitColorUtils.accentColorKeyForTypeIndex(type, index);

        await txn.update(
          habitsTable,
          {'accent_color_key': accentColorKey},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    });
  }

  Future<void> _createWeeklySummariesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $weeklySummariesTable (
        id TEXT PRIMARY KEY,
        week_start_date TEXT NOT NULL UNIQUE,
        week_end_date TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        total_goal_hits INTEGER NOT NULL,
        total_slips INTEGER NOT NULL,
        total_logged_days INTEGER NOT NULL DEFAULT 0,
        total_logged_habits INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final rows = await db.query(
      habitsTable,
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return rows.map(Habit.fromMap).toList();
  }

  Future<List<HabitLog>> getHabitLogs() async {
    final db = await database;
    final rows = await db.query(habitLogsTable, orderBy: 'date DESC');
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<List<WeeklySummary>> getWeeklySummaries() async {
    final db = await database;
    final rows = await db.query(
      weeklySummariesTable,
      orderBy: 'week_start_date ASC',
    );
    return rows.map(WeeklySummary.fromMap).toList();
  }

  Future<WeeklySummary?> getWeeklySummaryForWeekStart(DateTime weekStart) async {
    final db = await database;
    final DateTime normalizedWeekStart = _dateOnly(weekStart);

    final rows = await db.query(
      weeklySummariesTable,
      where: 'week_start_date = ?',
      whereArgs: [normalizedWeekStart.toIso8601String()],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return WeeklySummary.fromMap(rows.first);
  }

  Future<WeeklySummary?> getMostRecentWeeklySummary() async {
    final db = await database;
    final rows = await db.query(
      weeklySummariesTable,
      orderBy: 'week_start_date DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return WeeklySummary.fromMap(rows.first);
  }

  Future<void> insertWeeklySummary(WeeklySummary summary) async {
    final db = await database;
    await db.insert(
      weeklySummariesTable,
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<DateTime?> getEarliestTrackedWeekStartDate() async {
    final db = await database;

    final habitRows = await db.query(
      habitsTable,
      columns: ['created_at'],
      orderBy: 'created_at ASC',
      limit: 1,
    );

    final logRows = await db.query(
      habitLogsTable,
      columns: ['date'],
      orderBy: 'date ASC',
      limit: 1,
    );

    DateTime? earliest;

    if (habitRows.isNotEmpty) {
      earliest = DateTime.parse(habitRows.first['created_at'] as String);
    }

    if (logRows.isNotEmpty) {
      final DateTime earliestLogDate = DateTime.parse(logRows.first['date'] as String);
      if (earliest == null || earliestLogDate.isBefore(earliest)) {
        earliest = earliestLogDate;
      }
    }

    if (earliest == null) {
      return null;
    }

    final DateTime day = _dateOnly(earliest);
    final int daysFromMonday = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: daysFromMonday));
  }

  Future<List<HabitLog>> getHabitLogsForDateRange(
    DateTime startDateInclusive,
    DateTime endDateExclusive,
  ) async {
    final db = await database;
    final rows = await db.query(
      habitLogsTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startDateInclusive.toIso8601String(),
        endDateExclusive.toIso8601String(),
      ],
      orderBy: 'date ASC',
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      habitsTable,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      habitsTable,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> updateHabitSortOrders(List<Habit> habits) async {
    if (habits.isEmpty) {
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      for (final habit in habits) {
        await txn.update(
          habitsTable,
          {'sort_order': habit.sortOrder},
          where: 'id = ?',
          whereArgs: [habit.id],
        );
      }
    });
  }

  Future<void> deleteHabit(String habitId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        habitLogsTable,
        where: 'habit_id = ?',
        whereArgs: [habitId],
      );

      await txn.delete(
        habitsTable,
        where: 'id = ?',
        whereArgs: [habitId],
      );
    });
  }

  Future<void> pauseHabit(String habitId, DateTime now) async {
    final db = await database;
    final DateTime day = _dateOnly(now);

    await db.update(
      habitsTable,
      {
        'is_paused': 1,
        'paused_at': day.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<void> resumeHabit(String habitId, DateTime now) async {
    final db = await database;
    final DateTime day = _dateOnly(now);

    await db.update(
      habitsTable,
      {
        'is_paused': 0,
        'resumed_at': day.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<void> insertHabitLog(HabitLog log) async {
    final db = await database;
    await db.insert(
      habitLogsTable,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitLog>> getHabitLogsForDate(DateTime date) async {
    final DateTime day = _dateOnly(date);
    return getHabitLogsForDateRange(
      day,
      day.add(const Duration(days: 1)),
    );
  }

  Future<void> upsertHabitLogForDate({
    required String habitId,
    required DateTime date,
    required HabitLogStatus status,
  }) async {
    final db = await database;
    final DateTime day = _dateOnly(date);

    await db.transaction((txn) async {
      final String datePrefix = _datePrefix(day);

      await txn.delete(
        habitLogsTable,
        where: 'habit_id = ? AND date LIKE ?',
        whereArgs: [habitId, '$datePrefix%'],
      );

      await txn.insert(
        habitLogsTable,
        HabitLog(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          habitId: habitId,
          date: day,
          status: status,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteHabitLogByDate(String habitId, DateTime date) async {
    final db = await database;
    final datePrefix = _datePrefix(date);

    await db.delete(
      habitLogsTable,
      where: 'habit_id = ? AND date LIKE ?',
      whereArgs: [habitId, '$datePrefix%'],
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _datePrefix(DateTime date) {
    final DateTime day = _dateOnly(date);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }
}
