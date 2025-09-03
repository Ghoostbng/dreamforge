import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dreamforge/services/api_service.dart';
import 'package:dreamforge/services/storage_service.dart';

class StoryboardScreen extends StatefulWidget {
  const StoryboardScreen({super.key});

  @override
  State<StoryboardScreen> createState() => _StoryboardScreenState();
}

class _StoryboardScreenState extends State<StoryboardScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final TextEditingController _promptController = TextEditingController();

  final List<Uint8List> _frames = [];
  bool _isLoading = false;

  Future<void> _generateStoryboard() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prompt')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _frames.clear();
    });

    try {
      final response = await _apiService.generateStoryboard(prompt, 4);
      if (response == null) {
        throw Exception('Erreur lors de la génération du storyboard');
      }

      final taskId = response['task_id'];
      
      // Attendre que le storyboard soit généré
      await Future.delayed(const Duration(seconds: 2));
      
      // Télécharger les images directement
      for (int i = 0; i < 4; i++) {
        try {
          final bytes = await _apiService.downloadStoryboardFrame(
            taskId: taskId,
            index: i,
          );
          if (bytes != null) {
            if (!mounted) return;
            setState(() {
              _frames.add(bytes);
            });
            await _storageService.saveBytesToFile(bytes, 'storyboard_${taskId}_frame_$i.png');
          }
        } catch (e) {
          debugPrint('Erreur frame $i: $e');
        }
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Storyboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: "Prompt storyboard",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateStoryboard,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Générer Storyboard"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _frames.isEmpty
                  ? const Center(child: Text("Aucune image générée"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _frames.length,
                      itemBuilder: (context, index) => Image.memory(
                        _frames[index],
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}