// lib/screens/generation_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dreamforge/services/api_service.dart';
import 'package:dreamforge/services/storage_service.dart';
import 'package:dreamforge/services/task_manager.dart';
import 'package:dreamforge/models/task.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  final List<Uint8List> _images = [];
  TaskStatus _currentStatus = TaskStatus.unknown;
  String? _currentTaskId;

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prompt')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _currentStatus = TaskStatus.pending;
      _images.clear();
      _currentTaskId = null;
    });

    try {
      final response = await _apiService.generateImage(prompt);
      
      if (response == null || !response.containsKey('task_id')) {
        throw Exception('Réponse invalide du serveur: $response');
      }

      final taskId = response['task_id'] as String?;

      if (taskId == null || taskId.isEmpty) {
        throw Exception('Aucun ID de tâche reçu');
      }

      setState(() {
        _currentStatus = TaskStatus.processing;
        _currentTaskId = taskId;
      });

      await TaskManager.saveTaskId(taskId);

      // Polling avec gestion améliorée
      bool isCompleted = false;
      int attempts = 0;
      const maxAttempts = 60; // 2 minutes max
      const delay = Duration(seconds: 2);

      while (attempts < maxAttempts && !isCompleted && mounted) {
        await Future.delayed(delay);
        
        final taskData = await _apiService.getTaskStatus(taskId);
        
        if (taskData != null) {
          final status = taskData['status']?.toString().toLowerCase();
          
          if (status == 'completed') {
            final resultUrls = taskData['result_urls'] as List<dynamic>?;
            if (resultUrls != null && resultUrls.isNotEmpty) {
              for (int i = 0; i < resultUrls.length; i++) {
                final imageUrl = resultUrls[i].toString();
                debugPrint('Tentative de téléchargement depuis: $imageUrl');
                
                final imageBytes = await _apiService.downloadImageFromUrl(imageUrl);
                if (imageBytes != null && mounted) {
                  setState(() {
                    _images.add(imageBytes);
                    _currentStatus = TaskStatus.completed;
                  });
                  await _storageService.saveBytesToFile(
                    imageBytes, 
                    'image_${taskId}_$i.png'
                  );
                }
              }
            }
            isCompleted = true;
          } else if (status == 'failed') {
            final error = taskData['error'] ?? 'Échec de la génération';
            throw Exception(error);
          } else if (status == 'processing') {
            // Continue polling
            setState(() {
              _currentStatus = TaskStatus.processing;
            });
          }
        }
        
        attempts++;
        
        if (attempts >= maxAttempts) {
          throw Exception('Délai d\'attente dépassé');
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStatus = TaskStatus.failed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération d\'images IA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Entrez votre prompt',
                border: OutlineInputBorder(),
                hintText: 'Décrivez l\'image que vous souhaitez générer',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateImage,
              child: _isGenerating
                  ? const CircularProgressIndicator()
                  : const Text('Générer l\'image'),
            ),
            const SizedBox(height: 16),
            if (_currentTaskId != null)
              Text(
                'ID de tâche: ${_currentTaskId!}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (_currentStatus != TaskStatus.unknown)
              Text(
                _currentStatus == TaskStatus.pending 
                    ? 'En attente...'
                    : _currentStatus == TaskStatus.processing
                        ? 'Génération en cours...'
                        : _currentStatus == TaskStatus.completed
                            ? 'Terminé!'
                            : 'Erreur',
                style: TextStyle(
                  color: _currentStatus == TaskStatus.failed 
                      ? Colors.red 
                      : Colors.grey[700],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _images.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucune image générée'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _images[index],
                              fit: BoxFit.cover,
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