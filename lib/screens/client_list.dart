import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List clients = []; // Lista de clientes
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  bool isLoading = true; // Indica se os dados estão sendo carregados
  bool isEditing = false; // Indica se está em modo de edição

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  // Fetch: Obter a lista de clientes
  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/api/testeApi.php/cliente/list'),
      );
      if (response.statusCode == 200) {
        setState(() {
          clients = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar clientes');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // POST: Adicionar cliente
  Future<void> addClient() async {
    try {
      final response = await http.post(
        Uri.parse('https://6907-2804-389-10ee-9832-d8c1-9094-67cc-5e33.ngrok-free.app/api/testeApi.php/cliente'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nameController.text,
          'categoria': categoryController.text,
        }),
      );
      if (response.statusCode == 200) {
        fetchClients(); // Atualiza a lista
        clearForm(); // Limpa os campos
      }
    } catch (e) {
      print('Erro ao adicionar cliente: $e');
    }
  }

  // PUT: Atualizar cliente
  Future<void> updateClient() async {
    try {
      final response = await http.put(
        Uri.parse('https://6907-2804-389-10ee-9832-d8c1-9094-67cc-5e33.ngrok-free.app/api/testeApi.php/cliente/${idController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nameController.text,
          'categoria': categoryController.text,
        }),
      );
      if (response.statusCode == 200) {
        fetchClients(); // Atualiza a lista
        clearForm(); // Limpa os campos
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
    }
  }

  // DELETE: Remover cliente
  Future<void> deleteClient(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://10.0.2.2/api/testeApi.php/cliente/$id'),
      );
      if (response.statusCode == 200) {
        fetchClients(); // Atualiza a lista
      }
    } catch (e) {
      print('Erro ao excluir cliente: $e');
    }
  }

  // Limpa os campos do formulário
  void clearForm() {
    idController.clear();
    nameController.clear();
    categoryController.clear();
  }

  // Seleciona um cliente para edição
  void selectClient(Map client) {
    setState(() {
      idController.text = client['id'];
      nameController.text = client['nome'];
      categoryController.text = client['categoria'];
      isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRUD API Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulário
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID', enabled: false),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isEditing ? updateClient : addClient,
                  child: Text(isEditing ? 'Atualizar' : 'Adicionar'),
                ),
                ElevatedButton(
                  onPressed: clearForm,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de Clientes
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nome')),
                    DataColumn(label: Text('Categoria')),
                    DataColumn(label: Text('Ações')),
                  ],
                  rows: clients.map((client) {
                    return DataRow(
                      cells: [
                        DataCell(Text(client['id'])),
                        DataCell(Text(client['nome'])),
                        DataCell(Text(client['categoria'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => selectClient(client),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteClient(client['id']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
