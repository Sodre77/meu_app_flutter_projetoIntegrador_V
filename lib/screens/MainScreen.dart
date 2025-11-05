// screens/MainScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/PedidosRepository.dart';
import '../providers/CardapioRepository.dart';
import '../models/Hamburguer.dart';
import '../models/Bebida.dart';
import '../models/Pedido.dart';

final Uuid uuid = Uuid();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _mesaController = TextEditingController();
  Hamburguer? _selectedHamburguer;
  Bebida? _selectedBebida;

  void _selectHamburguer(Hamburguer item) {
    setState(() {
      _selectedHamburguer = (_selectedHamburguer != null && _selectedHamburguer!.nome == item.nome) ? null : item;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hambúrguer: ${item.nome} selecionado.")),
    );
  }

  void _selectBebida(Bebida item) {
    setState(() {
      _selectedBebida = (_selectedBebida != null && _selectedBebida!.nome == item.nome) ? null : item;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bebida: ${item.nome} selecionada.")),
    );
  }

  void _salvarPedidoENavegar() {
    final mesa = _mesaController.text.trim();

    if (mesa.isEmpty) {
      _showToast("Por favor, insira o número da mesa.");
      return;
    }

    if (_selectedHamburguer == null || _selectedBebida == null) {
      _showToast("Selecione um hambúrguer E uma bebida para fechar o pedido.");
      return;
    }

    final novoPedido = Pedido(
      id: uuid.v4(),
      numeroMesa: mesa,
      itemHamburguer: _selectedHamburguer!,
      itemBebida: _selectedBebida!,
    );

    Provider.of<PedidosRepository>(context, listen: false).adicionarPedido(novoPedido);

    setState(() {
      _selectedHamburguer = null;
      _selectedBebida = null;
      _mesaController.clear();
    });

    Navigator.of(context).pushNamed('/pedidos');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHamburguerList(BuildContext context, List<Hamburguer> hamburgueres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Hambúrgueres", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hamburgueres.length,
          itemBuilder: (context, index) {
            final item = hamburgueres[index];
            final bool isSelected = _selectedHamburguer != null && _selectedHamburguer!.nome == item.nome;
            return ItemCardapio(
              nome: item.nome,
              precoExibicao: 'R\$ ${item.preco.toStringAsFixed(2)}',
              isSelected: isSelected,
              onTap: () => _selectHamburguer(item),
              color: Colors.green,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBebidasList(BuildContext context, List<Bebida> bebidas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Bebidas para Acompanhar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bebidas.length,
          itemBuilder: (context, index) {
            final item = bebidas[index];
            final bool isSelected = _selectedBebida != null && _selectedBebida!.nome == item.nome;
            return ItemCardapio(
              nome: item.nome,
              precoExibicao: 'R\$ ${item.preco.toStringAsFixed(2)}',
              isSelected: isSelected,
              onTap: () => _selectBebida(item),
              color: Colors.blue,
            );
          },
        ),
      ],
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
              // Área do Número da Mesa
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

              // Área de Conteúdo Rolável (Cardápio)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHamburguerList(context, hamburgueres),
                      const SizedBox(height: 20),
                      _buildBebidasList(context, bebidas),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botão Flutuante para FINALIZAR O PEDIDO
          floatingActionButton: FloatingActionButton(
            onPressed: _salvarPedidoENavegar,
            tooltip: 'Finalizar Pedido',
            child: const Icon(Icons.send),
          ),
        );
      },
    );
  }
}


// Widget auxiliar ItemCardapio
class ItemCardapio extends StatelessWidget {
  final String nome;
  final String precoExibicao;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const ItemCardapio({
    super.key,
    required this.nome,
    required this.precoExibicao,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        elevation: 2,
        color: isSelected ? Colors.lightBlue.shade100 : Colors.white,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                precoExibicao,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}