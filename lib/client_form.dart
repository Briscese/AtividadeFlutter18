import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClientFormScreen extends StatefulWidget {
  final Map? client;

  ClientFormScreen({this.client});

  @override
  _ClientFormScreenState createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      nameController.text = widget.client!['nome'];
      categoryController.text = widget.client!['categoria'];
    }
  }

  Future<void> saveClient() async {
    final isEditing = widget.client != null;
    final url = isEditing
        ? 'http://localhost/api/testeApi.php/cliente/${widget.client!['id']}'
        : 'http://localhost/api/testeApi.php/cliente';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': nameController.text,
        'categoria': categoryController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      throw Exception('Erro ao salvar cliente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client != null ? 'Editar Cliente' : 'Adicionar Cliente')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveClient,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
