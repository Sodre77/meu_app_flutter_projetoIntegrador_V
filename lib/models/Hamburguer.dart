// models/Hamburguer.dart
class Hamburguer {
  final String nome;
  final double preco;

  Hamburguer({required this.nome, required this.preco});

  // NOVO: Getter para retornar o preço formatado para exibição (R$ XX.XX)
  String get precoExibicao => 'R\$ ${preco.toStringAsFixed(2)}';
}