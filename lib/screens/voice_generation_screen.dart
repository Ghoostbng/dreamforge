// lib/screens/voice_settings_screen.dart
import 'package:flutter/material.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key}); // Ajout super.key

  @override
  _VoiceSettingsScreenState createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  String _selectedService = "bark";
  String _selectedVoice = "default";
  double _pitch = 0.5;
  double _speed = 1.0;

  final List<String> _barkVoices = ["default", "fr_speaker_0", "fr_speaker_1"];
  final List<String> _elevenLabsVoices = ["Rachel", "Domi", "Bella"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres vocaux"), // Ajout const
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Service de synthèse vocale"), // Ajout const
            DropdownButton<String>(
              value: _selectedService,
              onChanged: (value) {
                setState(() {
                  _selectedService = value!;
                  _selectedVoice = _getVoicesForService().first;
                });
              },
              items: ["bark", "elevenlabs"].map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service == "bark" ? "Bark TTS" : "ElevenLabs"),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Voix"), // Ajout const
            DropdownButton<String>(
              value: _selectedVoice,
              onChanged: (value) {
                setState(() {
                  _selectedVoice = value!;
                });
              },
              items: _getVoicesForService().map((voice) {
                return DropdownMenuItem(
                  value: voice,
                  child: Text(voice),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text("Tonalité: ${_pitch.toStringAsFixed(2)}"),
            Slider(
              value: _pitch,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _pitch = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text("Vitesse: ${_speed.toStringAsFixed(2)}"),
            Slider(
              value: _speed,
              min: 0.5,
              max: 2.0,
              onChanged: (value) {
                setState(() {
                  _speed = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text("Enregistrer les paramètres"), // Ajout const
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getVoicesForService() {
    return _selectedService == "bark" ? _barkVoices : _elevenLabsVoices;
  }

  void _saveSettings() {
    Navigator.pop(context, {
      'service': _selectedService,
      'voice': _selectedVoice,
      'pitch': _pitch,
      'speed': _speed,
    });
  }
}