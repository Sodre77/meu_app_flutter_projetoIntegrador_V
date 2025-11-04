// screens/PedidosScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/PedidosRepository.dart';
import '../models/Pedido.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa o Consumer para escutar mudanças no PedidosRepository.
    // Sempre que notifyListeners() for chamado no Repository, este widget será reconstruído.
    return Consumer<PedidosRepository>(
      builder: (context, pedidosRepository, child) {
        final listaDePedidos = pedidosRepository.pedidosEmAberto;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pedidos em Aberto'),
            actions: [
              // Botão para limpar a lista de pedidos (opcional, para testes ou funcionalidade)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Limpar todos os pedidos',
                onPressed: () {
                  // Chama o método para limpar todos os pedidos do repositório
                  pedidosRepository.limparTodosPedidos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todos os pedidos foram removidos!")),
                  );
                },
              ),
            ],
          ),
          body: listaDePedidos.isEmpty
              ? const Center(
            child: Text(
              'Nenhum pedido em aberto. Comece na tela principal.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
              : ListView.builder(
            itemCount: listaDePedidos.length,
            itemBuilder: (context, index) {
              final pedido = listaDePedidos[index];
              return PedidoCard(
                pedido: pedido,
                pedidosRepository: pedidosRepository,
              );
            },
          ),
        );
      },
    );
  }
}

// Widget auxiliar para exibir cada pedido em um Card (reutilizável)
class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final PedidosRepository pedidosRepository;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.pedidosRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            pedido.numeroMesa,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        title: Text(
          'Mesa ${pedido.numeroMesa}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Total: ${pedido.valorTotalExibicao}', // Usa o getter formatado do Pedido
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão para ver os detalhes do pedido
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              onPressed: () {
                // Navega para a tela de detalhes, passando o ID do pedido
                Navigator.of(context).pushNamed(
                  '/detalhes_pedido',
                  arguments: pedido.id,
                );
              },
            ),
            // Botão para finalizar/remover o pedido
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                pedidosRepository.finalizarPedido(pedido.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Pedido da Mesa ${pedido.numeroMesa} finalizado!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}