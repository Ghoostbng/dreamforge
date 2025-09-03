// lib/screens/timeline_editor_screen.dart
import 'package:flutter/material.dart';

class TimelineEditorScreen extends StatefulWidget {
  const TimelineEditorScreen({super.key}); // Ajout super.key

  @override
  _TimelineEditorScreenState createState() => _TimelineEditorScreenState();
}

class _TimelineEditorScreenState extends State<TimelineEditorScreen> {
  final List<Scene> _scenes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Éditeur de timeline"), // Ajout const
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Ajout const
            onPressed: _addNewScene,
          ),
        ],
      ),
      body: ListView( // Remplacement ReorderableColumn
        children: [
          ..._scenes.map((scene) => _buildSceneCard(scene)),
        ],
      ),
    );
  }

  Widget _buildSceneCard(Scene scene) {
    return Card(
      key: ValueKey(scene.id),
      child: ListTile(
        title: Text(scene.prompt),
        subtitle: Text("Durée: ${scene.duration}s"),
        trailing: IconButton(
          icon: const Icon(Icons.delete), // Ajout const
          onPressed: () => _removeScene(scene.id),
        ),
      ),
    );
  }

  void _addNewScene() {
    setState(() {
      _scenes.add(Scene(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: "Nouvelle scène",
        duration: 5,
      ));
    });
  }

  void _removeScene(String id) {
    setState(() {
      _scenes.removeWhere((scene) => scene.id == id);
    });
  }
}

class Scene {
  final String id;
  String prompt;
  int duration;
  String? voice;

  Scene({
    required this.id,
    required this.prompt,
    required this.duration,
    this.voice,
  });
}