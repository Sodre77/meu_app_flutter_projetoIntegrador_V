// screens/DetalhePedidoScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Pedido.dart';
import '../providers/PedidosRepository.dart';

class DetalhePedidoScreen extends StatelessWidget {
  static const routeName = '/detalhes_pedido';

  const DetalhePedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O ID do pedido é passado como argumento na navegação
    final pedidoId = ModalRoute.of(context)!.settings.arguments as String;

    // Acessa o repositório para buscar o pedido
    final repository = Provider.of<PedidosRepository>(context, listen: false);

    // Busca o pedido na lista em memória (que está sincronizada com o SQLite)
    final Pedido? pedido = repository.getPedidoById(pedidoId);

    // Se o pedido não for encontrado (ex: já foi finalizado ou limpou o banco)
    if (pedido == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pedido Não Encontrado'),
        ),
        body: const Center(
          child: Text('Este pedido não está mais em aberto.'),
        ),
      );
    }

    // Se o pedido for encontrado
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido da Mesa ${pedido.numeroMesa}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Título
            const Text(
              'Detalhes do Pedido:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const Divider(height: 20, thickness: 2),

            // Informações do Hamburguer
            _buildDetailCard(
              context,
              title: 'Hambúrguer',
              items: [
                'Nome: ${pedido.itemHamburguer.nome}',
                'Preço: R\$ ${pedido.itemHamburguer.preco.toStringAsFixed(2)}',
              ],
              color: Colors.red[100]!,
            ),

            const SizedBox(height: 20),

            // Informações da Bebida
            _buildDetailCard(
              context,
              title: 'Bebida',
              items: [
                'Nome: ${pedido.itemBebida.nome}',
                'Preço: R\$ ${pedido.itemBebida.preco.toStringAsFixed(2)}',
              ],
              color: Colors.teal[100]!,
            ),

            const SizedBox(height: 30),

            // Botão de Ação (Finalizar Pedido)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('FINALIZAR PEDIDO', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Finaliza o pedido no repositório (e no SQLite)
                  repository.finalizarPedido(pedido.id);

                  // Retorna para a tela anterior (PedidosScreen)
                  Navigator.of(context).pop();

                  // Exibe uma SnackBar de confirmação
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pedido da Mesa ${pedido.numeroMesa} finalizado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir os cartões de detalhe
  Widget _buildDetailCard(BuildContext context, {required String title, required List<String> items, required Color color}) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(item, style: const TextStyle(fontSize: 16)),
            )).toList(),
          ],
        ),
      ),
    );
  }
}