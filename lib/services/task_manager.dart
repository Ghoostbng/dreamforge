// lib/services/task_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class TaskManager {
  static const String _imageTaskIdsKey = "image_task_ids";
  static const int _maxStoredTasks = 50;

  // Sauvegarder un ID de tâche avec timestamp
  static Future<void> saveTaskId(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList(_imageTaskIdsKey) ?? [];
    
    // Ajouter le timestamp au format ISO8601
    final timestamp = DateTime.now().toIso8601String();
    final taskWithTimestamp = '$timestamp|$taskId';
    
    tasks.insert(0, taskWithTimestamp);
    
    // Limiter le nombre de tâches stockées
    if (tasks.length > _maxStoredTasks) {
      tasks.removeRange(_maxStoredTasks, tasks.length);
    }
    
    await prefs.setStringList(_imageTaskIdsKey, tasks);
  }

  // Récupérer les IDs de tâches
  static Future<List<String>> getTaskIds() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList(_imageTaskIdsKey) ?? [];
    
    // Extraire seulement les IDs de tâche
    return tasks.map((taskStr) {
      final parts = taskStr.split('|');
      return parts.length > 1 ? parts[1] : taskStr;
    }).toList();
  }

  // Autres méthodes utiles...
  static Future<void> clearTaskIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imageTaskIdsKey);
  }
  
  static Future<void> removeTaskId(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList(_imageTaskIdsKey) ?? [];
    
    // Trouver et supprimer la tâche (avec ou sans timestamp)
    tasks.removeWhere((taskStr) => taskStr.contains(taskId));
    
    await prefs.setStringList(_imageTaskIdsKey, tasks);
  }
}