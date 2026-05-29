import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';

class NetworkScreen extends StatefulWidget {
  @override
  _NetworkScreenState createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final _idController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isLoading = false;
  Post? _currentPost;

  // Método GET
  Future<void> fetchPost() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/${_idController.text}'));
      if (response.statusCode == 200) {
        setState(() {
          _currentPost = Post.fromJson(jsonDecode(response.body));
          _titleController.text = _currentPost!.title;
          _bodyController.text = _currentPost!.body;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método PUT
  Future<void> updatePost() async {
    if (_currentPost == null) return;
    setState(() => _isLoading = true);

    _currentPost!.title = _titleController.text;
    _currentPost!.body = _bodyController.text;

    try {
      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/${_currentPost!.id}'),
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: jsonEncode(_currentPost!.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Actualizado con éxito (Fake API)!')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Módulo 1: API REST')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ID del Post'),
              keyboardType: TextInputType.number,
              enabled: !_isLoading, // Bloquea si está cargando
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : fetchPost,
              child: const Text('Obtener'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_currentPost != null) ...[
              const Divider(),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                enabled: !_isLoading,
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Cuerpo'),
                enabled: !_isLoading,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : updatePost,
                child: const Text('Actualizar'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}