// models/Bebida.dart
class Bebida {
  final String nome;
  final double preco; // CORRIGIDO: Agora é double

  Bebida({
    required this.nome,
    required this.preco,
  });

  // NOVO: Getter para retornar o preço formatado para exibição (R$ XX.XX)
  String get precoExibicao => 'R\$ ${preco.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bebida &&
        other.nome == nome &&
        other.preco == preco;
  }

  @override
  int get hashCode => nome.hashCode ^ preco.hashCode;
}