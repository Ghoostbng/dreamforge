// lib/screens/export_screen.dart
import 'package:flutter/material.dart';
import 'package:dreamforge/services/api_service.dart'; // Import ajouté

class ExportScreen extends StatefulWidget {
  final String videoPath;

  const ExportScreen({super.key, required this.videoPath}); // Correction: super.key

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _selectedFormat = "tiktok";
  bool _isExporting = false;
  String? _exportedUrl;

  final Map<String, String> _formatDescriptions = {
    "tiktok": "Format vertical 9:16 (1080x1920)",
    "youtube": "Format horizontal 16:9 (1920x1080)",
    "insta": "Format carré 1:1 (1080x1080)",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exporter la vidéo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Format d'exportation"), // Ajout const
            DropdownButton<String>(
              value: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              items: ["tiktok", "youtube", "insta"].map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text("${format.toUpperCase()} - ${_formatDescriptions[format]}"),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isExporting)
              const Center( // Ajout const
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Exportation en cours..."),
                  ],
                ),
              )
            else if (_exportedUrl != null)
              Column(
                children: [
                  const Text("Exportation terminée!"), // Ajout const
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Télécharger ou partager la vidéo
                    },
                    child: const Text("Télécharger la vidéo"), // Ajout const
                  ),
                ],
              )
            else
              Center(
                child: ElevatedButton(
                  onPressed: _exportVideo,
                  child: const Text("Exporter la vidéo"), // Ajout const
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _exportVideo() async {
    setState(() {
      _isExporting = true;
    });

    final apiService = ApiService();
    final result = await apiService.exportVideo(widget.videoPath, _selectedFormat);

    if (!mounted) return; // Vérification mounted
    setState(() {
      _isExporting = false;
    });

    if (result != null && result['status'] == 'completed') {
      setState(() {
        _exportedUrl = result['output_url'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'exportation")), // Ajout const
      );
    }
  }
}