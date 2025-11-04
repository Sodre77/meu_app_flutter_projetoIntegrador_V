// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa suas classes e repositórios
import 'providers/PedidosRepository.dart';
import 'screens/MainScreen.dart';
import 'screens/PedidosScreen.dart' hide DetalhePedidoScreen;     // Importa a classe PedidosScreen
import 'screens/DetalhePedidoScreen.dart'; // Importa a classe DetalhePedidoScreen


// O PONTO DE ENTRADA PRINCIPAL: A função main é necessária para rodar o app
void main() {
  runApp(
    // Usa ChangeNotifierProvider para injetar a instância única do PedidosRepository
    // na raiz da árvore de widgets, tornando-o acessível a todas as telas
    ChangeNotifierProvider(
      create: (context) => PedidosRepository(),
      child: const CardapioApp(),
    ),
  );
}

class CardapioApp extends StatelessWidget {
  const CardapioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardapio.App',
      theme: ThemeData(
        // Define a cor primária do aplicativo
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Define a tela que será aberta primeiro
      initialRoute: '/',

      // Define as rotas nomeadas do aplicativo
      routes: {
        // Rota principal: Tela de fazer o pedido
        '/': (context) => const MainScreen(),

        // Rota para a lista de todos os pedidos
        '/pedidos': (context) => const PedidosScreen(),

        // Rota para os detalhes de um pedido específico
        '/detalhes_pedido': (context) => const DetalhePedidoScreen(),
      },
    );
  }
}

