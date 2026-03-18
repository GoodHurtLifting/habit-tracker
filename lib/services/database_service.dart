import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String _databaseName = 'habit_tracker.db';
  static const int _databaseVersion = 2;

  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';

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
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $habitsTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            type TEXT NOT NULL,
            created_at TEXT NOT NULL,
            milestone_track_id TEXT
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $habitsTable ADD COLUMN milestone_track_id TEXT',
          );
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final rows = await db.query(habitsTable, orderBy: 'created_at ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<List<HabitLog>> getHabitLogs() async {
    final db = await database;
    final rows = await db.query(habitLogsTable, orderBy: 'date DESC');
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

  Future<void> deleteHabit(String habitId) async {
    final db = await database;
    await db.delete(
      habitsTable,
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

  Future<void> deleteHabitLogByDate(String habitId, DateTime date) async {
    final db = await database;
    final datePrefix = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await db.delete(
      habitLogsTable,
      where: 'habit_id = ? AND date LIKE ?',
      whereArgs: [habitId, '$datePrefix%'],
    );
  }
}
