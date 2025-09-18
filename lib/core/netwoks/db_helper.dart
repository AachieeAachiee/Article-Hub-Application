import 'package:flutter/physics.dart';
import 'package:path/path.dart';
import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
import 'package:sqflite/sqflite.dart';

import '../features/register_screen/model/register_models.dart';

class DBHelper {
  static Database? _db;
  static const _table ='cached_articles';
  // static const _dbname = 'rimes_article.db';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'user.db');
    print("DB PAth : ${path}");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT,
            username TEXT,
            email TEXT,
            phone TEXT,
            position TEXT,
            country TEXT,
            createAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertUser(RegisterModels user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  Future<List<RegisterModels>> getUsers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('users');
    return maps.map((map) => RegisterModels.fromMap(map)).toList();
  }


//Article 
Future<void> insertOrReplaceArticle(Article a) async {
    final dbClient = await db;
    await dbClient.insert('cached_articles',a.toMap(),
      
     conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<List<Article>> getAllCachedArticles() async {
    final dbClient = await db;
    final rows = await dbClient.query('cached_articles', orderBy: 'createdAt DESC');
    return rows.map((r) => Article.fromMapLocal(r)).toList();
  }

  Future<Article?> getCachedArticleById(String id) async {
    final dbClient = await db;
    final rows = await dbClient.query('cached_articles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Article.fromMapLocal(rows.first);
  }


 Future<void> deleteCachedArticle(String id) async {
    final dbClient = await db;
    await dbClient.delete('cached_articles',where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllCached() async {
    final dbClient = await db;
    await dbClient.delete(_table);
  }



  Future<void> deleteAllUsers() async {
    final dbClient = await db;
    await dbClient.delete('users');
  }
}