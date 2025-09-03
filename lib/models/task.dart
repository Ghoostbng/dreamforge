// lib/models/task.dart

enum TaskStatus { pending, processing, completed, failed, unknown }

extension TaskStatusExtension on TaskStatus {
  String get name {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.processing:
        return 'processing';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.failed:
        return 'failed';
      case TaskStatus.unknown:
        return 'unknown';
    }
  }

  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'processing':
        return TaskStatus.processing;
      case 'completed':
        return TaskStatus.completed;
      case 'failed':
        return TaskStatus.failed;
      default:
        return TaskStatus.unknown;
    }
  }
}

class Task {
  final String taskId;
  final TaskStatus status;
  final Map<String, dynamic>? metadata;
  final List<String> resultUrls; // ✅ corrigé
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? prompt;

  Task({
    required this.taskId,
    required this.status,
    this.metadata,
    this.resultUrls = const [],
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
    this.prompt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'] as String? ?? '',
      status: _parseStatus(json['status']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      resultUrls: _parseResultUrls(json['result_urls'] ?? []), // ✅
      errorMessage: json['error_message'] ?? json['error'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      prompt: json['prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'status': status.name,
        'metadata': metadata,
        'result_urls': resultUrls, // ✅
        'error_message': errorMessage,
        'prompt': prompt,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  bool get isCompleted => status == TaskStatus.completed;
  bool get isFailed => status == TaskStatus.failed;
  bool get isProcessing => status == TaskStatus.processing;
  bool get isPending => status == TaskStatus.pending;

  String get statusMessage {
    switch (status) {
      case TaskStatus.pending:
        return "En attente...";
      case TaskStatus.processing:
        return "En cours de traitement...";
      case TaskStatus.completed:
        return "Tâche terminée";
      case TaskStatus.failed:
        return errorMessage ?? "Échec de la tâche";
      case TaskStatus.unknown:
        return "Statut inconnu";
    }
  }

  Task copyWith({
    String? taskId,
    TaskStatus? status,
    Map<String, dynamic>? metadata,
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? prompt,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      resultUrls: resultUrls ?? this.resultUrls,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prompt: prompt ?? this.prompt,
    );
  }

  static TaskStatus _parseStatus(dynamic status) {
    if (status == null) return TaskStatus.unknown;
    final statusString = status.toString().toLowerCase();
    return TaskStatusExtension.fromString(statusString);
  }

  static List<String> _parseResultUrls(dynamic urls) {
    if (urls == null) return [];
    if (urls is! List) return [];
    return urls
        .map((url) => url?.toString())
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && taskId == other.taskId;

  @override
  int get hashCode => taskId.hashCode;

  String formatCreatedAt() {
    if (createdAt == null) return 'Date inconnue';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} à ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  String get processingDuration {
    if (createdAt == null || updatedAt == null) return 'Durée inconnue';
    final duration = updatedAt!.difference(createdAt!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return minutes > 0 ? '$minutes min ${seconds}s' : '${seconds}s';
  }
}
