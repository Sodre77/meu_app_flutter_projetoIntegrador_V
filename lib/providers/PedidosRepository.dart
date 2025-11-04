// providers/PedidosRepository.dart
import 'package:flutter/foundation.dart'; // Necessário para ChangeNotifier
import '../models/Pedido.dart'; // Importa a classe Pedido

class PedidosRepository with ChangeNotifier {
  // Lista privada onde os pedidos são armazenados
  final List<Pedido> _pedidos = [];

  // ==========================================================
  // 1. GETTER CORRIGIDO: Resolve o erro da linha 17 (image_590f1a.png)
  // Retorna uma cópia da lista de pedidos para que ela não seja alterada externamente
  // e seja usada para exibição na PedidosScreen.
  List<Pedido> get pedidosEmAberto => [..._pedidos];
  // ==========================================================


  // Método para adicionar um novo pedido (usado na MainScreen)
  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners(); // Avisa a todos os Consumers (incluindo PedidosScreen) para atualizar
  }

  // Método para buscar um pedido por ID (usado na DetalhePedidoScreen)
  Pedido? getPedidoById(String id) {
    try {
      // Busca o pedido que corresponde ao ID
      return _pedidos.firstWhere((pedido) => pedido.id == id);
    } catch (e) {
      // Retorna nulo se o pedido não for encontrado
      return null;
    }
  }

  // ==========================================================
  // 2. MÉTODO CORRIGIDO: Resolve o erro da linha 110 (image_5912e1.png)
  void finalizarPedido(String id) {
    // Remove o pedido da lista onde o ID corresponde
    _pedidos.removeWhere((pedido) => pedido.id == id);
    notifyListeners(); // Avisa a PedidosScreen que a lista mudou
  }
  // ==========================================================

  // ==========================================================
  // 3. MÉTODO CORRIGIDO: Resolve o erro da linha 29 (image_590fd4.png)
  void limparTodosPedidos() {
    _pedidos.clear(); // Limpa toda a lista
    notifyListeners(); // Avisa a PedidosScreen que a lista mudou (agora vazia)
  }
// ==========================================================
}