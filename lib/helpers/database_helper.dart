// helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "cardapio.db";
  static const _databaseVersion = 1;

  // Usa o singleton para garantir que haja apenas uma instância do DB
  DatabaseHelper._privateConstructor();
  // INSTÂNCIA CORRETA
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // MÉTODO _onCreate: CRIA AS TABELAS ESSENCIAIS
  Future _onCreate(Database db, int version) async {

    // 1. Tabela de Pedidos
    await db.execute('''
      CREATE TABLE pedidos (
        id TEXT PRIMARY KEY,
        numeroMesa TEXT NOT NULL,
        hamburguerNome TEXT NOT NULL,
        hamburguerPreco REAL NOT NULL,
        bebidaNome TEXT NOT NULL,
        bebidaPreco REAL NOT NULL
      )
    ''');

    // 2. Tabela para Itens de Cardápio
    await db.execute('''
      CREATE TABLE cardapio_itens (
        nome TEXT PRIMARY KEY,
        preco REAL NOT NULL,
        tipo TEXT NOT NULL -- 'Hamburguer' ou 'Bebida'
      )
    ''');
  }
}