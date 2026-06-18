class QualificationModel {
  final String id;
  final String title;
  final String description;
  final List<String> features;
  final String? image;
  final bool gold;
  final String? redirectUrl;
  final int order;
  final bool isActive;

  const QualificationModel({
    required this.id,
    required this.title,
    required this.description,
    this.features = const [],
    this.image,
    this.gold = false,
    this.redirectUrl,
    this.order = 0,
    this.isActive = true,
  });

  factory QualificationModel.fromJson(Map<String, dynamic> j) => QualificationModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        features: List<String>.from(j['features'] ?? []),
        image: j['image'],
        gold: j['gold'] ?? false,
        redirectUrl: j['redirectUrl'],
        order: (j['order'] as num?)?.toInt() ?? 0,
        isActive: j['isActive'] ?? true,
      );
}
