// models/Pedido.dart (ATUALIZADO)

import 'dart:convert'; // Necessário para converter List<Map> em String JSON
import 'ItemPedido.dart';

class Pedido {
  final String id;
  final String numeroMesa;
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.numeroMesa,
    required this.itens,
  });

  String get tituloExibicao => 'Pedido Mesa $numeroMesa';

  double get valorTotal {
    return itens.fold(0.0, (sum, item) => sum + item.subTotal);
  }

  String get valorTotalExibicao {
    return 'R\$ ${valorTotal.toStringAsFixed(2)}';
  }

  // =========================================================================
  // MÉTODOS DE SERIALIZAÇÃO PARA SQLite
  // =========================================================================

  Map<String, dynamic> toMap() {
    // Converte a lista de ItemPedido em uma lista de Map
    final List<Map<String, dynamic>> itensMapList =
    itens.map((item) => item.toMap()).toList();

    // Converte a lista de Map em uma String JSON para salvar no SQLite
    final String itensJson = json.encode(itensMapList);

    return {
      'id': id,
      'numeroMesa': numeroMesa,
      'itensJson': itensJson, // Novo campo para armazenar a lista de itens
    };
  }

  static Pedido fromMap(Map<String, dynamic> map) {
    // Pega a string JSON do banco de dados
    final String itensJson = map['itensJson'] as String;

    // Converte a string JSON de volta para List<Map<String, dynamic>>
    final List<dynamic> itensMapList = json.decode(itensJson);

    // Converte a lista de Map de volta para List<ItemPedido>
    final List<ItemPedido> itensList =
    itensMapList.map((map) => ItemPedido.fromMap(map as Map<String, dynamic>)).toList();

    return Pedido(
      id: map['id'] as String,
      numeroMesa: map['numeroMesa'] as String,
      itens: itensList,
    );
  }
}