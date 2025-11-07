// screens/DetalhePedidoScreen.dart (ATUALIZADO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/PedidosRepository.dart';
import '../models/ItemPedido.dart'; // Import necessário

class DetalhePedidoScreen extends StatelessWidget {
  static const routeName = '/detalhes_pedido';

  const DetalhePedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidoId = ModalRoute.of(context)!.settings.arguments as String;
    final repository = Provider.of<PedidosRepository>(context, listen: false);
    final pedido = repository.getPedidoById(pedidoId);

    if (pedido == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pedido Não Encontrado')),
        body: const Center(child: Text('Este pedido não está mais em aberto.')),
      );
    }

    // Separa os itens por tipo para exibição organizada
    final List<ItemPedido> hamburgueres = pedido.itens.where((item) => item.tipo == 'Hamburguer').toList();
    final List<ItemPedido> bebidas = pedido.itens.where((item) => item.tipo == 'Bebida').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes: Mesa ${pedido.numeroMesa}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Itens do Pedido:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const Divider(height: 20, thickness: 2),

                  // Exibe a lista de Hambúrgueres
                  if (hamburgueres.isNotEmpty)
                    _buildItemListSection(
                      context,
                      title: 'Hambúrgueres',
                      items: hamburgueres,
                      color: Colors.red[100]!,
                      icon: Icons.lunch_dining,
                    ),

                  const SizedBox(height: 20),

                  // Exibe a lista de Bebidas
                  if (bebidas.isNotEmpty)
                    _buildItemListSection(
                      context,
                      title: 'Bebidas',
                      items: bebidas,
                      color: Colors.teal[100]!,
                      icon: Icons.local_drink,
                    ),

                  if (hamburgueres.isEmpty && bebidas.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text("Pedido sem itens registrados.", style: TextStyle(color: Colors.grey)),
                    )),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Rodapé Fixo com Total e Botão de Finalizar
          _buildTotalFooter(context, pedido.valorTotal, pedido.numeroMesa, pedidoId, repository),
        ],
      ),
    );
  }

  // Widget auxiliar para construir a seção de itens (Hambúrguer ou Bebida)
  Widget _buildItemListSection(BuildContext context, {required String title, required List<ItemPedido> items, required Color color, required IconData icon}) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 10, thickness: 1),

            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantidade}x ${item.nome}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    'R\$ ${item.subTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir o rodapé do total
  Widget _buildTotalFooter(BuildContext context, double total, String mesa, String pedidoId, PedidosRepository repository) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL DO PEDIDO:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('FINALIZAR PEDIDO', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              repository.finalizarPedido(pedidoId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pedido da Mesa $mesa finalizado!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }
}