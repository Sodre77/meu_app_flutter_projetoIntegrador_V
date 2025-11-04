// helpers/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  // Singleton Pattern: Garante que haja apenas uma instância do banco de dados
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pedidos.db');

    // Abre o banco de dados. Se não existir, ele será criado.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Cria as tabelas do banco de dados
  Future _onCreate(Database db, int version) async {
    // Tabela de Pedidos
    await db.execute('''
      CREATE TABLE pedidos (
        id TEXT PRIMARY KEY,
        numeroMesa TEXT,
        itemHamburguerNome TEXT,
        itemHamburguerPreco REAL,
        itemBebidaNome TEXT,
        itemBebidaPreco REAL
      )
    ''');
  }
}