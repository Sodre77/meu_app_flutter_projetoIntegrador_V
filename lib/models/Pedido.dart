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

  // NOVO: Getter para calcular o preço total do pedido
  double get valorTotal {
    return itemHamburguer.preco + itemBebida.preco;
  }

  // NOVO: Getter para exibir o total formatado
  String get valorTotalExibicao {
    // Formata o valor com duas casas decimais
    return 'R\$ ${valorTotal.toStringAsFixed(2)}';
  }
  // Mapeia o objeto Pedido para um Map (Formato usado pelo SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroMesa': numeroMesa,
      'itemHamburguerNome': itemHamburguer.nome,
      'itemHamburguerPreco': itemHamburguer.preco,
      'itemBebidaNome': itemBebida.nome,
      'itemBebidaPreco': itemBebida.preco,
    };
  }

  // Cria um objeto Pedido a partir de um Map (Lido do SQLite)
  static Pedido fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      numeroMesa: map['numeroMesa'],
      itemHamburguer: Hamburguer(
        nome: map['itemHamburguerNome'],
        preco: map['itemHamburguerPreco'],
      ),
      itemBebida: Bebida(
        nome: map['itemBebidaNome'],
        preco: map['itemBebidaPreco'],
      ),
    );
  }
}
