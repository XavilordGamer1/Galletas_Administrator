import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

/// Clase auxiliar para gestionar la base de datos SQLite.
/// Se encarga de abrir la base de datos y proporcionar métodos
/// para insertar, consultar y eliminar registros.
class DBHelper {
  /// Abre (o crea si no existe) la base de datos.
  /// Define la estructura de las tablas en el evento `onCreate`.
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'galletas.db'),
        onCreate: (db, version) {
      // Ejecuta la sentencia SQL para crear la tabla 'cookies'.
      return db.execute(
          'CREATE TABLE cookies(id TEXT PRIMARY KEY, nombre TEXT, descripcion TEXT, precio REAL)');
    }, version: 1);
  }

  /// Inserta un nuevo registro en una tabla específica.
  /// Utiliza `ConflictAlgorithm.replace` para que si un registro con el mismo
  /// id ya existe, sea reemplazado.
  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todos los registros de una tabla.
  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  /// Elimina un registro de una tabla por su id.
  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
