// providers/PedidosRepository.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Pedido.dart';
import '../helpers/database_helper.dart'; // Importa o nosso Helper

class PedidosRepository with ChangeNotifier {
  // Lista em memória continua sendo a fonte de verdade para a UI
  List<Pedido> _pedidos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Flag para saber se os dados já foram carregados
  bool _isLoading = true;

  PedidosRepository() {
    // Carrega os dados do banco de dados quando o Repositório é criado
    _loadPedidosFromDatabase();
  }

  // Getter para a lista
  List<Pedido> get pedidosEmAberto => _pedidos;

  // Getter para verificar se os dados foram carregados
  bool get isLoading => _isLoading;


  // ==========================================================
  // LÓGICA DE PERSISTÊNCIA (CREATE, READ, UPDATE, DELETE)
  // ==========================================================

  Future<void> _loadPedidosFromDatabase() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pedidos');

    // Converte a lista de Maps do SQL para a lista de objetos Pedido
    _pedidos = List.generate(maps.length, (i) {
      return Pedido.fromMap(maps[i]);
    });

    _isLoading = false;
    notifyListeners();
  }

  // 1. ADICIONAR (CREATE)
  void adicionarPedido(Pedido pedido) async {
    final db = await _dbHelper.database;

    // Insere no banco de dados (A linha que estava com erro)
    await db.insert(
      'pedidos',
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // <--- Agora será reconhecido
    );

    // Adiciona na lista em memória e notifica
    _pedidos.add(pedido);
    notifyListeners();
  }

  // 2. FINALIZAR (DELETE)
  void finalizarPedido(String id) async {
    final db = await _dbHelper.database;

    // Remove do banco de dados
    await db.delete(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Remove da lista em memória e notifica
    _pedidos.removeWhere((pedido) => pedido.id == id);
    notifyListeners();
  }

  // 3. LIMPAR TODOS (DELETE ALL)
  void limparTodosPedidos() async {
    final db = await _dbHelper.database;

    // Remove todos os registros do banco
    await db.delete('pedidos');

    // Limpa a lista em memória e notifica
    _pedidos.clear();
    notifyListeners();
  }

  // 4. VERIFICAÇÃO DE CONTEÚDO (READ BY ID)
  // metodo sera usado da DetalhePedido
  Pedido? getPedidoById(String id) {
    try {
      // Busca na lista em memória (já carregada do banco)
      return _pedidos.firstWhere((pedido) => pedido.id == id);
    } catch (e) {
      return null;
    }
  }
}