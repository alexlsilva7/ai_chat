import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/chat_message.dart';
import 'chat_local_datasource.dart';
import 'database_helper.dart';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final DatabaseHelper _dbHelper;

  ChatLocalDataSourceImpl(this._dbHelper);

  @override
  Future<List<ChatSession>> getSessions() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sessions', orderBy: 'created_at DESC');
    return maps.map((map) => ChatSession.fromMap(map)).toList();
  }

  @override
  Future<void> saveSession(ChatSession session) async {
    final db = await _dbHelper.database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSession(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => ChatMessage.fromMap(map)).toList();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    final db = await _dbHelper.database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateSessionTitle(String sessionId, String title) async {
    final db = await _dbHelper.database;
    await db.update(
      'sessions',
      {'title': title},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<void> updateSessionModel(String sessionId, String model) async {
    final db = await _dbHelper.database;
    await db.update(
      'sessions',
      {'model': model},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
