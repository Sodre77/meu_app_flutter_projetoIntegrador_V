// screens/detalhe_pedido_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import '../models/Pedido.dart';
import '../providers/PedidosRepository.dart';


class DetalhePedidoScreen extends StatelessWidget {
  const DetalhePedidoScreen({super.key});

  get Provider => null;

  @override
  Widget build(BuildContext context) {
    // Recebe o ID do pedido passado como argumento de rota
    final pedidoId = ModalRoute.of(context)!.settings.arguments as String;

    // Acessa o repositório para buscar o pedido
    final repository = Provider.of<PedidosRepository>(context, listen: false);
    final Pedido? pedido = repository.getPedidoById(pedidoId);

    if (pedido == null) {
      // Se o pedido não for encontrado
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Erro: Pedido não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(pedido.tituloExibicao)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detalhes do Pedido",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2), // Cor primária
              ),
            ),
            const Divider(height: 40),

            _buildDetailRow(
              context,
              title: "Mesa:",
              value: pedido.numeroMesa,
            ),

            const SizedBox(height: 20),

            _buildDetailRow(
              context,
              title: "Hambúrguer Selecionado:",
              value: "${pedido.itemHamburguer.nome} (${pedido.itemHamburguer.preco})",
            ),

            const SizedBox(height: 20),

            _buildDetailRow(
              context,
              title: "Bebida Selecionada:",
              value: "${pedido.itemBebida.nome} (${pedido.itemBebida.preco})",
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para formatar a linha de detalhes
  Widget _buildDetailRow(BuildContext context, {required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}
