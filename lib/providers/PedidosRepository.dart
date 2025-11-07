// providers/PedidosRepository.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/Pedido.dart';
import '../helpers/database_helper.dart';

class PedidosRepository with ChangeNotifier {
  List<Pedido> _pedidos = [];

  // SINGLETON: Garante a instância única do banco de dados
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  PedidosRepository() {
    _loadPedidosFromDatabase();
  }

  // Getter
  List<Pedido> get pedidosEmAberto {
    return [..._pedidos];
  }

  // =========================================================================
  // OPERAÇÕES DO BANCO DE DADOS
  // =========================================================================

  Future<void> _loadPedidosFromDatabase() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pedidos');

    // Mapeia os Maps lidos do banco para objetos Pedido (que fazem a decodificação do JSON internamente)
    _pedidos = maps.map((map) => Pedido.fromMap(map)).toList();

    notifyListeners();
  }

  void adicionarPedido(Pedido pedido) async {
    final db = await _dbHelper.database;

    // O método toMap() do Pedido já converte a lista de itens para JSON
    await db.insert(
      'pedidos',
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _pedidos.add(pedido);
    notifyListeners();
  }

  Pedido? getPedidoById(String id) {
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (e) {
      // Retorna null se não encontrar o pedido
      return null;
    }
  }

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

  void limparTodosPedidos() async {
    final db = await _dbHelper.database;

    await db.delete('pedidos');

    _pedidos.clear();
    notifyListeners();
  }
}