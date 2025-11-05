// screens/CardapioEditScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Bebida.dart';
import '../models/Hamburguer.dart';
import '../providers/CardapioRepository.dart';

class CardapioEditScreen extends StatelessWidget {
  static const routeName = '/editar_cardapio';

  const CardapioEditScreen({super.key});

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddItemModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardapioRepository>(
      builder: (context, cardapioRepo, child) {
        final hamburgueres = cardapioRepo.hamburgueres;
        final bebidas = cardapioRepo.bebidas;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Editar Cardápio'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Hambúrgueres', icon: Icon(Icons.lunch_dining)),
                  Tab(text: 'Bebidas', icon: Icon(Icons.local_drink)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Adicionar Novo Item',
                  onPressed: () => _showAddItemModal(context),
                )
              ],
            ),
            body: TabBarView(
              children: [
                _buildItemList(context, 'Hambúrgueres', hamburgueres),
                _buildItemList(context, 'Bebidas', bebidas),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemList(BuildContext context, String categoria, List<dynamic> itens) {
    final cardapioRepo = Provider.of<CardapioRepository>(context, listen: false);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: itens.length,
      itemBuilder: (context, index) {
        final item = itens[index];
        final String nome = item.nome;
        final double preco = item.preco;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Preço: R\$ ${preco.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Editar $nome (WIP)')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, cardapioRepo, categoria, nome);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CardapioRepository repo, String categoria, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja remover "$nome" do cardápio de $categoria?'),
        actions: <Widget>[
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () {
              if (categoria == 'Hambúrgueres') {
                repo.removerHamburguer(nome);
              } else if (categoria == 'Bebidas') {
                repo.removerBebida(nome);
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$nome removido com sucesso!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET AUXILIAR: MODAL PARA ADICIONAR NOVO ITEM
// =========================================================================

class AddItemModal extends StatefulWidget {
  const AddItemModal({super.key});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  double _preco = 0.0;
  String _tipoSelecionado = 'Hambúrguer';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final repo = Provider.of<CardapioRepository>(context, listen: false);

      if (_tipoSelecionado == 'Hambúrguer') {
        final novoItem = Hamburguer(nome: _nome, preco: _preco);
        repo.adicionarHamburguer(novoItem);
      } else {
        final novoItem = Bebida(nome: _nome, preco: _preco);
        repo.adicionarBebida(novoItem);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_nome adicionado ao cardápio!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Adicionar Novo Item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),

              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de Item'),
                items: const ['Hambúrguer', 'Bebida']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (value) => setState(() => _tipoSelecionado = value!),
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.isEmpty) ? 'O nome é obrigatório.' : null,
                onSaved: (value) => _nome = value!,
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'O preço é obrigatório.';
                  if (double.tryParse(value.replaceAll(',', '.')) == null || double.parse(value.replaceAll(',', '.')) <= 0) {
                    return 'Insira um preço válido maior que zero.';
                  }
                  return null;
                },
                onSaved: (value) => _preco = double.parse(value!.replaceAll(',', '.')),
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: _submitForm, child: const Text('Salvar Item')),
            ],
          ),
        ),
      ),
    );
  }
}