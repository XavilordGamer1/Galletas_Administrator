import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'galletas.db'),
        onCreate: (db, version) {
      // Usar un batch para ejecutar múltiples sentencias en una sola transacción.
      final batch = db.batch();
      // Crea la tabla de galletas.
      batch.execute(
          'CREATE TABLE cookies(id TEXT PRIMARY KEY, nombre TEXT, descripcion TEXT, precio REAL)');
      // CAMBIO: Crea la tabla de ventas con la nueva columna para la fecha de pago.
      batch.execute(
          'CREATE TABLE ventas(id TEXT PRIMARY KEY, codigoEscaneado TEXT, fecha TEXT, esFiado INTEGER, nombreDeudor TEXT, fechaPago TEXT)');
      return batch.commit();
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object?> data) async {
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

  static Future<void> update(
      String table, String id, Map<String, Object?> data) async {
    final db = await DBHelper.database();
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
