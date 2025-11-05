// models/Pedido.dart

import 'Bebida.dart';
import 'Hamburguer.dart';

class Pedido {
  final String id;
  final String numeroMesa;
  final Hamburguer itemHamburguer;
  final Bebida itemBebida;

  Pedido({
    required this.id,
    required this.numeroMesa,
    required this.itemHamburguer,
    required this.itemBebida,
  });

  String get tituloExibicao => 'Pedido Mesa $numeroMesa';

  double get valorTotal {
    return itemHamburguer.preco + itemBebida.preco;
  }

  String get valorTotalExibicao {
    return 'R\$ ${valorTotal.toStringAsFixed(2)}';
  }

  // Mapeia o objeto Pedido para um Map (Chaves sincronizadas com database_helper)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroMesa': numeroMesa,
      // Chaves corretas (hamburguerNome/Preco, bebidaNome/Preco)
      'hamburguerNome': itemHamburguer.nome,
      'hamburguerPreco': itemHamburguer.preco,
      'bebidaNome': itemBebida.nome,
      'bebidaPreco': itemBebida.preco,
    };
  }

  // Cria um objeto Pedido a partir de um Map (Lido do SQLite)
  static Pedido fromMap(Map<String, dynamic> map) {
    // Função auxiliar para desserializar com segurança (evita erros int/double)
    double safeDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return Pedido(
      id: map['id'] as String,
      numeroMesa: map['numeroMesa'] as String,
      itemHamburguer: Hamburguer(
        nome: map['hamburguerNome'] as String,
        preco: safeDouble(map['hamburguerPreco']),
      ),
      itemBebida: Bebida(
        nome: map['bebidaNome'] as String,
        preco: safeDouble(map['bebidaPreco']),
      ),
    );
  }
}