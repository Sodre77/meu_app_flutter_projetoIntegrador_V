// providers/PedidosRepository.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/Pedido.dart';
import '../helpers/database_helper.dart';

class PedidosRepository with ChangeNotifier {
  List<Pedido> _pedidos = [];
  // CORREÇÃO: Usando a instância Singleton
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // Mantido, mas não essencial na UI

  PedidosRepository() {
    _loadPedidosFromDatabase();
  }

  // GETTER ESSENCIAL
  List<Pedido> get pedidosEmAberto {
    return [..._pedidos];
  }

  Future<void> _loadPedidosFromDatabase() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pedidos');

    _pedidos = maps.map((map) => Pedido.fromMap(map)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // 1. ADICIONAR NOVO PEDIDO (CREATE)
  void adicionarPedido(Pedido pedido) async {
    final db = await _dbHelper.database;

    await db.insert(
      'pedidos',
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _pedidos.add(pedido);
    notifyListeners();
  }

  // 2. BUSCAR POR ID (READ)
  Pedido? getPedidoById(String id) {
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. FINALIZAR/REMOVER PEDIDO (DELETE único)
  void finalizarPedido(String id) async {
    final db = await _dbHelper.database;

    await db.delete(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );

    _pedidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // 4. LIMPAR TODOS OS PEDIDOS (DELETE ALL)
  void limparTodosPedidos() async {
    final db = await _dbHelper.database;

    await db.delete('pedidos');

    _pedidos.clear();
    notifyListeners();
  }
}