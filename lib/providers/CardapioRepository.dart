// providers/CardapioRepository.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/Hamburguer.dart';
import '../models/Bebida.dart';
import '../helpers/database_helper.dart';

class CardapioRepository with ChangeNotifier {
  List<Hamburguer> _hamburgueres = [];
  List<Bebida> _bebidas = [];
  // CORREÇÃO: Usando a instância Singleton
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  CardapioRepository() {
    _loadCardapioFromDatabase();
  }

  // =========================================================================
  // CARREGAMENTO E MOCK INICIAL
  // =========================================================================

  Future<void> _loadCardapioFromDatabase() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cardapio_itens');

    _hamburgueres.clear();
    _bebidas.clear();

    for (var map in maps) {
      if (map['tipo'] == 'Hamburguer') {
        _hamburgueres.add(Hamburguer.fromMap(map));
      } else if (map['tipo'] == 'Bebida') {
        _bebidas.add(Bebida.fromMap(map));
      }
    }

    // Se o banco estiver vazio, popula com mock inicial
    if (_hamburgueres.isEmpty && _bebidas.isEmpty) {
      await _populateInitialMock(db);
    }

    notifyListeners();
  }

  Future<void> _populateInitialMock(Database db) async {
    final initialHamburgueres = [
      Hamburguer(nome: "Clássico Bacon", preco: 25.00),
      Hamburguer(nome: "Duplo Cheddar", preco: 30.00),
      Hamburguer(nome: "Vegetariano Gourmet", preco: 28.00),
      Hamburguer(nome: "Especial da Casa", preco: 35.00),
    ];
    final initialBebidas = [
      Bebida(nome: "Coca-Cola 350ml", preco: 6.00),
      Bebida(nome: "Guaraná Antarctica 350ml", preco: 5.50),
      Bebida(nome: "Água sem Gás", preco: 4.00),
      Bebida(nome: "Cerveja Artesanal IPA", preco: 18.00),
    ];

    for (var h in initialHamburgueres) {
      await db.insert('cardapio_itens', h.toMap('Hamburguer'), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (var b in initialBebidas) {
      await db.insert('cardapio_itens', b.toMap('Bebida'), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    _hamburgueres = initialHamburgueres;
    _bebidas = initialBebidas;
  }

  // =========================================================================
  // GETTERS e MÉTODOS CRUD
  // =========================================================================

  List<Hamburguer> get hamburgueres => [..._hamburgueres];
  List<Bebida> get bebidas => [..._bebidas];

  void adicionarHamburguer(Hamburguer novoHamburguer) async {
    final db = await _dbHelper.database;
    await db.insert('cardapio_itens', novoHamburguer.toMap('Hamburguer'), conflictAlgorithm: ConflictAlgorithm.replace);
    _hamburgueres.add(novoHamburguer);
    notifyListeners();
  }

  void removerHamburguer(String nome) async {
    final db = await _dbHelper.database;
    await db.delete('cardapio_itens', where: 'nome = ? AND tipo = ?', whereArgs: [nome, 'Hamburguer']);
    _hamburgueres.removeWhere((h) => h.nome == nome);
    notifyListeners();
  }

  void adicionarBebida(Bebida novaBebida) async {
    final db = await _dbHelper.database;
    await db.insert('cardapio_itens', novaBebida.toMap('Bebida'), conflictAlgorithm: ConflictAlgorithm.replace);
    _bebidas.add(novaBebida);
    notifyListeners();
  }

  void removerBebida(String nome) async {
    final db = await _dbHelper.database;
    await db.delete('cardapio_itens', where: 'nome = ? AND tipo = ?', whereArgs: [nome, 'Bebida']);
    _bebidas.removeWhere((b) => b.nome == nome);
    notifyListeners();
  }
}