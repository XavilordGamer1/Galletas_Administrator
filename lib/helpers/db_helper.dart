import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

/// Clase auxiliar para gestionar la base de datos SQLite.
class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'galletas.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE cookies(id TEXT PRIMARY KEY, nombre TEXT, descripcion TEXT, precio REAL)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// --- NUEVO MÉTODO PARA ACTUALIZAR ---
  /// Actualiza un registro en la tabla basado en su id.
  static Future<void> update(
      String table, String id, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
