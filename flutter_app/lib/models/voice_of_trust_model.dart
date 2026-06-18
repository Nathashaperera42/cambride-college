class VoiceOfTrustModel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final int order;
  final bool isActive;

  const VoiceOfTrustModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.order = 0,
    this.isActive = true,
  });

  factory VoiceOfTrustModel.fromJson(Map<String, dynamic> j) => VoiceOfTrustModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        image: j['image'],
        order: (j['order'] as num?)?.toInt() ?? 0,
        isActive: j['isActive'] ?? true,
      );
}
