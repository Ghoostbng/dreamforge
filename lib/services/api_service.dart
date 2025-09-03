// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final http.Client _client = http.Client();
  final String _baseUrl = 'http://192.168.2.24:8000'; // Base URL sans /api
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>?> generateImage(String prompt) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/image/generate'),
        headers: _headers,
        body: jsonEncode({'prompt': prompt, 'style': 'default'}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateImage: $e');
      return null;
    }
  }

  // CORRECTION: Route corrigée pour storyboard
  Future<Map<String, dynamic>?> generateStoryboard(String prompt, int frameCount) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/storyboard/generate'), // CORRIGÉ
        headers: _headers,
        body: jsonEncode({
          'prompt': prompt,
          'frame_count': frameCount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateStoryboard: $e');
      return null;
    }
  }

  // CORRECTION: Route corrigée pour téléchargement de frame
  Future<Uint8List?> downloadStoryboardFrame({required String taskId, required int index}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/storyboard/frame/$taskId/$index'), // CORRIGÉ
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur downloadStoryboardFrame: $e');
      return null;
    }
  }

  // CORRECTION: Route corrigée pour génération de voix
  Future<Map<String, dynamic>?> generateVoice(String text) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/bark/generate'), // CORRIGÉ
        headers: _headers,
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateVoice: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadVoiceAudio({required String taskId}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/bark/$taskId/download'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur downloadVoiceAudio: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTaskStatus(String taskId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/task/$taskId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur getTaskStatus: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadImage(String taskId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/download/image/$taskId'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur downloadImage: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadImageFromUrl(String imageUrl) async {
    try {
      final response = await _client.get(
        Uri.parse(imageUrl),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur downloadImageFromUrl: $e');
      return null;
    }
  }

  // NOUVELLES FONCTIONNALITÉS

  Future<Map<String, dynamic>?> generateVideo(String prompt, {int duration = 5, String resolution = "720p"}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/video/generate'),
        headers: _headers,
        body: jsonEncode({
          'prompt': prompt,
          'duration': duration,
          'resolution': resolution
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateVideo: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateVoiceElevenLabs(String text, {String voiceId = "Rachel"}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/voice/elevenlabs'),
        headers: _headers,
        body: jsonEncode({
          'text': text,
          'voice_id': voiceId
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateVoiceElevenLabs: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSoundEffects(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/sound/effects?query=$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur getSoundEffects: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> exportVideo(String inputPath, String format) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/export/video'),
        headers: _headers,
        body: jsonEncode({
          'input_path': inputPath,
          'format': format
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur exportVideo: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateAdvancedStoryboard(List<Map<String, dynamic>> scenes) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/advanced/storyboard/generate'),
        headers: _headers,
        body: jsonEncode({
          'scenes': scenes,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur generateAdvancedStoryboard: $e');
      return null;
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}