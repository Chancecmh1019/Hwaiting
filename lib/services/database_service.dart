import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/study_progress.dart';
import '../models/study_goal.dart';
import '../models/study_note.dart';
import '../models/mock_exam.dart';
import '../models/study_resource.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hwaiting.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 學習進度表
    await db.execute('''
      CREATE TABLE study_progress(
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        time_spent INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        confidence_level INTEGER,
        tags TEXT
      )
    ''');

    // 學習目標表
    await db.execute('''
      CREATE TABLE study_goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        start_date TEXT NOT NULL,
        target_date TEXT NOT NULL,
        target_hours INTEGER NOT NULL,
        current_hours INTEGER,
        is_completed INTEGER,
        subjects TEXT,
        priority INTEGER
      )
    ''');

    // 學習筆記表
    await db.execute('''
      CREATE TABLE study_notes(
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        tags TEXT,
        importance INTEGER,
        related_topics TEXT,
        image_url TEXT
      )
    ''');

    // 模擬考試表
    await db.execute('''
      CREATE TABLE mock_exams(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        exam_date TEXT NOT NULL,
        scores TEXT NOT NULL,
        mistakes TEXT,
        notes TEXT
      )
    ''');

    // 學習資源表
    await db.execute('''
      CREATE TABLE study_resources(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        url TEXT NOT NULL,
        type TEXT NOT NULL,
        subject TEXT NOT NULL,
        tags TEXT,
        rating REAL,
        view_count INTEGER,
        created_at TEXT NOT NULL,
        is_recommended INTEGER,
        thumbnail_url TEXT
      )
    ''');
  }

  // 學習進度相關操作
  Future<void> insertStudyProgress(StudyProgress progress) async {
    final db = await database;
    await db.insert(
      'study_progress',
      {
        'id': progress.id,
        'subject': progress.subject,
        'topic': progress.topic,
        'time_spent': progress.timeSpent,
        'date': progress.date.toIso8601String(),
        'notes': progress.notes,
        'confidence_level': progress.confidenceLevel,
        'tags': progress.tags.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyProgress>> getStudyProgressByDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_progress',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return StudyProgress(
        id: maps[i]['id'],
        subject: maps[i]['subject'],
        topic: maps[i]['topic'],
        timeSpent: maps[i]['time_spent'],
        date: DateTime.parse(maps[i]['date']),
        notes: maps[i]['notes'],
        confidenceLevel: maps[i]['confidence_level'],
        tags: maps[i]['tags'].split(','),
      );
    });
  }

  // 學習目標相關操作
  Future<void> insertStudyGoal(StudyGoal goal) async {
    final db = await database;
    await db.insert(
      'study_goals',
      {
        'id': goal.id,
        'title': goal.title,
        'description': goal.description,
        'start_date': goal.startDate.toIso8601String(),
        'target_date': goal.targetDate.toIso8601String(),
        'target_hours': goal.targetHours,
        'current_hours': goal.currentHours,
        'is_completed': goal.isCompleted ? 1 : 0,
        'subjects': goal.subjects.join(','),
        'priority': goal.priority,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyGoal>> getActiveStudyGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_goals',
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'priority DESC, target_date ASC',
    );

    return List.generate(maps.length, (i) {
      return StudyGoal(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        startDate: DateTime.parse(maps[i]['start_date']),
        targetDate: DateTime.parse(maps[i]['target_date']),
        targetHours: maps[i]['target_hours'],
        currentHours: maps[i]['current_hours'],
        isCompleted: maps[i]['is_completed'] == 1,
        subjects: maps[i]['subjects'].split(','),
        priority: maps[i]['priority'],
      );
    });
  }

  Future<void> updateStudyGoalProgress(String id, int currentHours) async {
    final db = await database;
    await db.update(
      'study_goals',
      {'current_hours': currentHours},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeStudyGoal(String id) async {
    final db = await database;
    await db.update(
      'study_goals',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 學習筆記相關操作
  Future<void> insertStudyNote(StudyNote note) async {
    final db = await database;
    await db.insert(
      'study_notes',
      {
        'id': note.id,
        'subject': note.subject,
        'title': note.title,
        'content': note.content,
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt.toIso8601String(),
        'tags': note.tags.join(','),
        'importance': note.importance,
        'related_topics': note.relatedTopics.join(','),
        'image_url': note.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyNote>> getStudyNotesBySubject(String subject) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_notes',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'importance DESC, updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return StudyNote(
        id: maps[i]['id'],
        subject: maps[i]['subject'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
        tags: maps[i]['tags'].split(','),
        importance: maps[i]['importance'],
        relatedTopics: maps[i]['related_topics'].split(','),
        imageUrl: maps[i]['image_url'],
      );
    });
  }

  Future<void> updateStudyNote(StudyNote note) async {
    final db = await database;
    await db.update(
      'study_notes',
      {
        'title': note.title,
        'content': note.content,
        'updated_at': DateTime.now().toIso8601String(),
        'tags': note.tags.join(','),
        'importance': note.importance,
        'related_topics': note.relatedTopics.join(','),
        'image_url': note.imageUrl,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteStudyNote(String id) async {
    final db = await database;
    await db.delete(
      'study_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 模擬考試相關操作
  Future<void> insertMockExam(MockExam exam) async {
    final db = await database;
    await db.insert(
      'mock_exams',
      {
        'id': exam.id,
        'title': exam.title,
        'exam_date': exam.examDate.toIso8601String(),
        'scores': exam.scores.entries.map((e) => '${e.key}:${e.value}').join(','),
        'mistakes': exam.mistakes.entries.map((e) => '${e.key}:${e.value.join('|')}').join(','),
        'notes': exam.notes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MockExam>> getAllMockExams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mock_exams', orderBy: 'exam_date DESC');
    return List.generate(maps.length, (i) {
      Map<String, int> scores = {};
      if (maps[i]['scores'] != null && maps[i]['scores'].toString().isNotEmpty) {
        for (var s in maps[i]['scores'].split(',')) {
          var kv = s.split(':');
          if (kv.length == 2) scores[kv[0]] = int.tryParse(kv[1]) ?? 0;
        }
      }
      Map<String, List<String>> mistakes = {};
      if (maps[i]['mistakes'] != null && maps[i]['mistakes'].toString().isNotEmpty) {
        for (var m in maps[i]['mistakes'].split(',')) {
          var kv = m.split(':');
          if (kv.length == 2) mistakes[kv[0]] = kv[1].split('|');
        }
      }
      return MockExam(
        id: maps[i]['id'],
        title: maps[i]['title'],
        examDate: DateTime.parse(maps[i]['exam_date']),
        scores: scores,
        mistakes: mistakes,
        notes: maps[i]['notes'],
      );
    });
  }

  // 學習資源相關操作
  Future<void> insertStudyResource(StudyResource resource) async {
    final db = await database;
    await db.insert(
      'study_resources',
      {
        'id': resource.id,
        'title': resource.title,
        'description': resource.description,
        'url': resource.url,
        'type': resource.type,
        'subject': resource.subject,
        'tags': resource.tags.join(','),
        'rating': resource.rating,
        'view_count': resource.viewCount,
        'created_at': resource.createdAt.toIso8601String(),
        'is_recommended': resource.isRecommended ? 1 : 0,
        'thumbnail_url': resource.thumbnailUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyResource>> getAllStudyResources() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_resources', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) {
      return StudyResource(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        url: maps[i]['url'],
        type: maps[i]['type'],
        subject: maps[i]['subject'],
        tags: maps[i]['tags'].split(','),
        rating: maps[i]['rating'],
        viewCount: maps[i]['view_count'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        isRecommended: maps[i]['is_recommended'] == 1,
        thumbnailUrl: maps[i]['thumbnail_url'],
      );
    });
  }
} 