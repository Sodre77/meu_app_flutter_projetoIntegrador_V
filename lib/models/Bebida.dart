// models/Bebida.dart

class Bebida {
  final String nome;
  final double preco;

  Bebida({
    required this.nome,
    required this.preco,
  });

  // Converte para Map para salvar no SQLite (tabela cardapio_itens)
  Map<String, dynamic> toMap(String tipo) {
    return {
      'nome': nome,
      'preco': preco,
      'tipo': tipo, // Deve ser 'Bebida'
    };
  }

  // Cria o objeto a partir de um Map lido do SQLite
  static Bebida fromMap(Map<String, dynamic> map) {
    return Bebida(
      nome: map['nome'] as String,
      // Garante que o preço seja um double
      preco: map['preco'] is int ? (map['preco'] as int).toDouble() : map['preco'] as double,
    );
  }
}