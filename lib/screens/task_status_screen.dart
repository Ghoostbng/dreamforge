// lib/screens/task_status_screen.dart
import 'dart:convert'; // Import ajouté
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TaskStatusScreen extends StatefulWidget {
  final String taskId;

  const TaskStatusScreen({super.key, required this.taskId}); // Correction: super.key

  @override
  _TaskStatusScreenState createState() => _TaskStatusScreenState();
}

class _TaskStatusScreenState extends State<TaskStatusScreen> {
  late WebSocketChannel _channel;
  double _progress = 0.0;
  String _status = "En attente";
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.2.24:8000/ws/task/${widget.taskId}'),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        _progress = data['progress'] ?? _progress;
        _status = data['status'] ?? _status;
        _previewUrl = data['preview_url'] ?? _previewUrl;
      });
    }, onError: (error) {
      debugPrint("WebSocket error: $error"); // Remplacement print
    }, onDone: () {
      debugPrint("WebSocket connection closed"); // Remplacement print
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statut de la tâche"), // Ajout const
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            const SizedBox(height: 20),
            Text("Progression: ${(_progress * 100).toStringAsFixed(0)}%"),
            const SizedBox(height: 10),
            Text("Status: $_status"),
            if (_previewUrl != null) ...[
              const SizedBox(height: 20),
              Image.network(
                'http://192.168.2.24:8000$_previewUrl',
                height: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}