import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://6907-2804-389-10ee-9832-d8c1-9094-67cc-5e33.ngrok-free.app';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List clients = [];
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/testeApi.php/cliente/list'),
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

  Future<void> addClient() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/testeApi.php/cliente'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nameController.text,
          'categoria': categoryController.text,
        }),
      );
      if (response.statusCode == 200) {
        fetchClients();
        clearForm();
      }
    } catch (e) {
      print('Erro ao adicionar cliente: $e');
    }
  }

  Future<void> updateClient() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/testeApi.php/cliente/${idController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nameController.text,
          'categoria': categoryController.text,
        }),
      );
      if (response.statusCode == 200) {
        fetchClients();
        clearForm();
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/testeApi.php/cliente/$id'),
      );
      if (response.statusCode == 200) {
        fetchClients();
      }
    } catch (e) {
      print('Erro ao excluir cliente: $e');
    }
  }

  void clearForm() {
    idController.clear();
    nameController.clear();
    categoryController.clear();
  }

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
            // Lista Vertical de Clientes
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        'ID: ${client['id']} - ${client['nome']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Categoria: ${client['categoria']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
