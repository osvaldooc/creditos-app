import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Acceso único a la base SQLite local (creditos.db).
/// La primera vez copia la base vacía desde assets/creditos.db.
class AppDb {
  static Database? _db;
  static const _nombre = 'creditos.db';
  static const _uuid = Uuid();

  /// Versión del esquema. Súbela cada vez que agregues/cambies tablas
  /// y añade el cambio correspondiente en [onUpgrade].
  static const _version = 2;

  static String newId() => _uuid.v4();

  static Future<String> dbPath() async {
    final dir = await getDatabasesPath();
    return p.join(dir, _nombre);
  }

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final path = await dbPath();

    // Si la base no existe, copia el asset (instalación nueva).
    if (!await File(path).exists()) {
      await Directory(p.dirname(path)).create(recursive: true);
      final data = await rootBundle.load('assets/$_nombre');
      await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    final db = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        // SQLite ignora las llaves foráneas si no se activa esto.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Se ejecuta solo en instalaciones NUEVAS.
        // Crea aquí las tablas que el asset no tenga.
        await db.execute('''
          CREATE TABLE IF NOT EXISTS zonas (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            municipio TEXT,
            activa INTEGER NOT NULL DEFAULT 1,
            creado_en TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Se ejecuta al ACTUALIZAR (archivo viejo -> versión nueva).
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS zonas (
              id TEXT PRIMARY KEY,
              nombre TEXT NOT NULL,
              municipio TEXT,
              activa INTEGER NOT NULL DEFAULT 1,
              creado_en TEXT NOT NULL DEFAULT (datetime('now'))
            )
          ''');
        }
      },
    );

    // Zona inicial para poder capturar solicitudes desde el primer uso.
    final zonas = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM zonas')) ??
        0;
    if (zonas == 0) {
      await db.insert('zonas', {
        'id': newId(),
        'nombre': 'Centro',
        'municipio': 'Puebla',
      });
    }

    _db = db;
    return db;
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Reemplaza la base actual por otra (por ejemplo, editada en DB Browser).
  static Future<void> replaceWith(String origen) async {
    final f = File(origen);
    final raf = await f.open();
    final header = await raf.read(15);
    await raf.close();
    if (String.fromCharCodes(header) != 'SQLite format 3') {
      throw Exception('El archivo no es una base SQLite válida');
    }
    await close();
    await f.copy(await dbPath());
  }
}
