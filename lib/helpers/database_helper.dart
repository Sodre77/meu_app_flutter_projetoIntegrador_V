// helpers/database_helper.dart (ATUALIZADO PARA SUPORTAR MULTI-ITENS NO PEDIDO)

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Nome e Versão do Banco de Dados
  static const _databaseName = "cardapio.db";
  static const _databaseVersion = 1;

  // =========================================================================
  // SINGLETON PATTERN (Garante apenas uma instância do banco de dados)
  // =========================================================================
  DatabaseHelper._privateConstructor();
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

  // =========================================================================
  // CRIAÇÃO DE TABELAS (ATUALIZADA)
  // =========================================================================
  Future _onCreate(Database db, int version) async {
    // 1. Tabela de Pedidos
    // Foi alterada para armazenar todos os itens do pedido como uma String JSON (itensJson)
    await db.execute('''
      CREATE TABLE pedidos (
        id TEXT PRIMARY KEY,
        numeroMesa TEXT NOT NULL,
        itensJson TEXT NOT NULL  -- NOVO CAMPO: Armazena a lista de ItemPedido serializada
      )
    ''');

    // 2. Tabela para Itens de Cardápio (MANTIDA)
    // Armazena a lista base de hambúrgueres e bebidas
    await db.execute('''
      CREATE TABLE cardapio_itens (
        nome TEXT PRIMARY KEY,
        preco REAL NOT NULL,
        tipo TEXT NOT NULL -- 'Hamburguer' ou 'Bebida'
      )
    ''');
  }
}