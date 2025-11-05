// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa suas classes e repositórios
import 'providers/PedidosRepository.dart';
import 'providers/CardapioRepository.dart';
import 'screens/MainScreen.dart';
import 'screens/PedidosScreen.dart';
import 'screens/DetalhePedidoScreen.dart';
import 'screens/CardapioEditScreen.dart';


void main() {
  // ESSENCIAL para sqflite/path_provider
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PedidosRepository()),
        ChangeNotifierProvider(create: (context) => CardapioRepository()),
      ],
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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',

      // Define as rotas nomeadas do aplicativo
      routes: {
        '/': (context) => const MainScreen(),
        '/pedidos': (context) => const PedidosScreen(),
        '/editar_cardapio': (context) => const CardapioEditScreen(),
        // Usamos a rota estática definida na tela
        DetalhePedidoScreen.routeName: (context) => const DetalhePedidoScreen(),
      },
    );
  }
}