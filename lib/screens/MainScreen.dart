// screens/MainScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/PedidosRepository.dart';
import '../providers/CardapioRepository.dart';
import '../models/Hamburguer.dart';
import '../models/Bebida.dart';
import '../models/Pedido.dart';
import '../models/ItemPedido.dart';

// Variável global para gerar IDs únicos (UUID)
final Uuid uuid = Uuid();

// =========================================================================
// WIDGET PRINCIPAL
// =========================================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _mesaController = TextEditingController();

  // Mapa para funcionar como um carrinho de compras
  final Map<String, ItemPedido> _carrinho = {};

  double get _valorTotalCarrinho {
    return _carrinho.values.fold(0.0, (sum, item) => sum + item.subTotal);
  }

  void _showToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
    }
  }

  // Lógica para abrir o modal de quantidade ao clicar no item do cardápio
  void _updateCarrinho<T>(T item, String tipo) {
    String nome;
    double preco;

    if (item is Hamburguer) {
      nome = item.nome;
      preco = item.preco;
    } else if (item is Bebida) {
      nome = item.nome;
      preco = item.preco;
    } else {
      return;
    }

    _showQuantityModal(nome, preco, tipo);
  }

  // =========================================================================
  // MODAL DE QUANTIDADE
  // =========================================================================

  void _showQuantityModal(String nome, double preco, String tipo) {
    int currentQuantity = _carrinho[nome]?.quantidade ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text('Quantidade: $nome'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Preço Unitário: R\$ ${preco.toStringAsFixed(2)}'),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Botão para diminuir
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: currentQuantity > 0 ? () {
                          setStateModal(() => currentQuantity--);
                        } : null,
                      ),
                      Text(
                        currentQuantity.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      // Botão para aumentar
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setStateModal(() => currentQuantity++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Subtotal: R\$ ${(preco * currentQuantity).toStringAsFixed(2)}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                    _processQuantityUpdate(nome, preco, tipo, currentQuantity);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // LÓGICA DE ATUALIZAÇÃO DO CARRINHO E SALVAR PEDIDO
  // =========================================================================

  void _processQuantityUpdate(String nome, double preco, String tipo, int novaQuantidade) {
    setState(() {
      if (novaQuantidade > 0) {
        _carrinho[nome] = ItemPedido(
          nome: nome,
          preco: preco,
          quantidade: novaQuantidade,
          tipo: tipo,
        );
        _showToast("$nome: Quantidade atualizada para $novaQuantidade.");
      } else if (_carrinho.containsKey(nome)) {
        _carrinho.remove(nome);
        _showToast("$nome foi removido do pedido.");
      }
    });
  }

  void _salvarPedidoENavegar() {
    final mesa = _mesaController.text.trim();

    if (mesa.isEmpty) {
      _showToast("Por favor, insira o número da mesa.");
      return;
    }

    if (_carrinho.isEmpty) {
      _showToast("O carrinho está vazio. Adicione itens para fechar o pedido.");
      return;
    }

    final listaItensPedido = _carrinho.values.toList();

    final novoPedido = Pedido(
      id: uuid.v4(),
      numeroMesa: mesa,
      itens: listaItensPedido,
    );

    Provider.of<PedidosRepository>(context, listen: false).adicionarPedido(novoPedido);
    final totalSalvo = _valorTotalCarrinho;

    setState(() {
      _carrinho.clear();
      _mesaController.clear();
    });

    _showToast("Pedido da Mesa $mesa registrado! Total: R\$ ${totalSalvo.toStringAsFixed(2)}");

    Navigator.of(context).pushNamed('/pedidos');
  }

  // =========================================================================
  // CONSTRUÇÃO DA INTERFACE
  // =========================================================================

  Widget _buildItemList<T>(BuildContext context, String title, List<T> itens, String tipo, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];
            String nome = (item is Hamburguer) ? item.nome : (item as Bebida).nome;
            double preco = (item is Hamburguer) ? item.preco : (item as Bebida).preco;

            final int quantidade = _carrinho[nome]?.quantidade ?? 0;
            final bool isInCart = quantidade > 0;

            return ItemCardapio(
              nome: nome,
              precoExibicao: 'R\$ ${preco.toStringAsFixed(2)}',
              quantidade: quantidade,
              isInCart: isInCart,
              onTap: () => _updateCarrinho(item, tipo),
              color: color,
            );
          },
        ),
      ],
    );
  }

  // WIDGET DO RESUMO DO CARRINHO (AGORA ROLÁVEL)
  Widget _buildCarrinhoSummary(BuildContext context) {
    final int totalItens = _carrinho.values.fold(0, (sum, item) => sum + item.quantidade);
    final isCarrinhoVazio = _carrinho.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isCarrinhoVazio ? Colors.grey[200] : Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCarrinhoVazio ? Colors.grey : Colors.green, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ITENS: $totalItens',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isCarrinhoVazio ? Colors.black54 : Colors.black),
                    ),
                    Text(
                      'TOTAL: R\$ ${_valorTotalCarrinho.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isCarrinhoVazio ? Colors.red : Colors.green.shade800),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botão para Finalizar Pedido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCarrinhoVazio ? null : _salvarPedidoENavegar,
                icon: const Icon(Icons.send),
                label: const Text('FINALIZAR PEDIDO', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardapioRepository>(
      builder: (context, cardapioRepo, child) {
        final hamburgueres = cardapioRepo.hamburgueres;
        final bebidas = cardapioRepo.bebidas;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cardapio.App - Fazer Pedido'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (String result) {
                  if (result == 'pedidos_aberto') {
                    Navigator.of(context).pushNamed('/pedidos');
                  } else if (result == 'editar_cardapio') {
                    Navigator.of(context).pushNamed('/editar_cardapio');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'pedidos_aberto',
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Pedidos em Aberto'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'editar_cardapio',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Editar Cardápio/Preços'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Área do Número da Mesa (FICA FIXA)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text("Número da Mesa:", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _mesaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Ex: 01",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Área de Conteúdo Rolável (Cardápio + Resumo do Carrinho)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildItemList<Hamburguer>(context, "Hambúrgueres", hamburgueres, "Hamburguer", Colors.green),
                      const SizedBox(height: 20),
                      _buildItemList<Bebida>(context, "Bebidas para Acompanhar", bebidas, "Bebida", Colors.blue),
                      const SizedBox(height: 30),

                      // RESUMO DO CARRINHO AGORA ESTÁ AQUI, DENTRO DA ÁREA ROLÁVEL
                      _buildCarrinhoSummary(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// WIDGET AUXILIAR: ItemCardapio
class ItemCardapio extends StatelessWidget {
  final String nome;
  final String precoExibicao;
  final int quantidade;
  final bool isInCart;
  final VoidCallback onTap;
  final Color color;

  const ItemCardapio({
    super.key,
    required this.nome,
    required this.precoExibicao,
    required this.quantidade,
    required this.isInCart,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        elevation: isInCart ? 4 : 2,
        color: isInCart ? color.withOpacity(0.1) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nome,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isInCart ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de Quantidade
                  if (isInCart)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'x$quantidade',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(width: 10),

                  // Preço
                  Text(
                    precoExibicao,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Botão de Ação (Adicionar/Editar)
                  Icon(
                    isInCart ? Icons.edit : Icons.add_circle_outline,
                    color: isInCart ? Colors.grey.shade700 : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}