// image_item.dart
class ImageItem {
  final String url;
  final String prompt;
  final DateTime? createdAt;

  ImageItem({
    required this.url,
    required this.prompt,
    this.createdAt,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      url: json['url'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'prompt': prompt,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  ImageItem copyWith({
    String? url,
    String? prompt,
    DateTime? createdAt,
  }) {
    return ImageItem(
      url: url ?? this.url,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageItem &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          prompt == other.prompt;

  @override
  int get hashCode => url.hashCode ^ prompt.hashCode;

  String get formattedDate {
    if (createdAt == null) return 'Date inconnue';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} à ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }
}