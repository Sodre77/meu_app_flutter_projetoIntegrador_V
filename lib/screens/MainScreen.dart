// screens/MainScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importação CORRETA do Provider
import 'package:uuid/uuid.dart'; // Importação NECESSÁRIA para Uuid

import '../providers/PedidosRepository.dart';
import '../models/Hamburguer.dart';
import '../models/Bebida.dart';
import '../models/Pedido.dart';

// Inicialização CORRETA do Uuid (fora de qualquer classe)
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

  // Mock de dados - CORRIGIDO: Preços agora são double (números)
  final List<Hamburguer> _listaDeHamb = [
    Hamburguer(nome: "Clássico Bacon", preco: 25.00),
    Hamburguer(nome: "Duplo Cheddar", preco: 30.00),
    Hamburguer(nome: "Vegetariano Gourmet", preco: 28.00),
    Hamburguer(nome: "Especial da Casa", preco: 35.00),
  ];

  final List<Bebida> _listaDeBebidas = [
    Bebida(nome: "Coca-Cola 350ml", preco: 6.00),
    Bebida(nome: "Guaraná Antarctica 350ml", preco: 5.50),
    Bebida(nome: "Água sem Gás", preco: 4.00),
    Bebida(nome: "Cerveja Artesanal IPA", preco: 18.00),
  ];

  // A variável 'var Provider;' foi removida!

  void _selectHamburguer(Hamburguer item) {
    setState(() {
      _selectedHamburguer = item;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hambúrguer: ${item.nome} selecionado.")),
    );
  }

  void _selectBebida(Bebida item) {
    setState(() {
      _selectedBebida = item;
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

    // Cria e salva o pedido
    final novoPedido = Pedido(
      id: uuid.v4(), // Uso correto do uuid
      numeroMesa: mesa,
      itemHamburguer: _selectedHamburguer!,
      itemBebida: _selectedBebida!,
    );

    // Adiciona ao repositório (usando Provider CORRETO)
    Provider.of<PedidosRepository>(context, listen: false).adicionarPedido(novoPedido);

    // Limpa a seleção e campos
    setState(() {
      _selectedHamburguer = null;
      _selectedBebida = null;
      _mesaController.clear();
    });

    // Navega para a Segundatela
    Navigator.of(context).pushNamed('/pedidos');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Widget para construir a lista de Hambúrgueres
  Widget _buildHamburguerList() {
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
          itemCount: _listaDeHamb.length,
          itemBuilder: (context, index) {
            final item = _listaDeHamb[index];
            final isSelected = item == _selectedHamburguer;
            return ItemCardapio(
              nome: item.nome,
              // USANDO O NOVO GETTER CORRETO do modelo Hamburguer
              precoExibicao: item.precoExibicao,
              isSelected: isSelected,
              onTap: () => _selectHamburguer(item),
              color: Colors.green, // Cor de destaque para preço
            );
          },
        ),
      ],
    );
  }

  // Widget para construir a lista de Bebidas
  Widget _buildBebidasList() {
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
          itemCount: _listaDeBebidas.length,
          itemBuilder: (context, index) {
            final item = _listaDeBebidas[index];
            final isSelected = item == _selectedBebida;
            return ItemCardapio(
              nome: item.nome,
              // USANDO O NOVO GETTER CORRETO do modelo Bebida
              precoExibicao: item.precoExibicao,
              isSelected: isSelected,
              onTap: () => _selectBebida(item),
              color: Colors.blue, // Cor de destaque para preço
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardapio.App - Fazer Pedido')),
      body: Column(
        children: [
          // Área do Número da Mesa (Header fixo)
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
                  _buildHamburguerList(),
                  const SizedBox(height: 20),
                  _buildBebidasList(),
                  const SizedBox(height: 80), // Espaço para o FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // Botão Flutuante (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: _salvarPedidoENavegar,
        tooltip: 'Finalizar Pedido',
        child: const Icon(Icons.send),
      ),
    );
  }
}


// Widget que representa item_hamburguer.xml e item_bebida.xml
class ItemCardapio extends StatelessWidget {
  final String nome;
  final String precoExibicao; // Recebe o preço já formatado do getter
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