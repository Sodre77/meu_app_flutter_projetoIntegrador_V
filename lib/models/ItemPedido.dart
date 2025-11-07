// models/ItemPedido.dart

class ItemPedido {
  final String nome;
  final double preco;
  final int quantidade;
  final String tipo; // "Hamburguer" ou "Bebida"

  ItemPedido({
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.tipo,
  });

  // Cálculo do subtotal
  double get subTotal => preco * quantidade;

  // Converte para Map (para salvar no JSON/SQLite)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'tipo': tipo,
    };
  }

  // Cria o objeto a partir de um Map
  static ItemPedido fromMap(Map<String, dynamic> map) {
    double safeDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return ItemPedido(
      nome: map['nome'] as String,
      preco: safeDouble(map['preco']),
      quantidade: map['quantidade'] as int,
      tipo: map['tipo'] as String,
    );
  }
}