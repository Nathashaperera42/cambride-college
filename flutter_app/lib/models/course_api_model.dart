class CourseImage {
  final String id;
  final String url;
  final String? publicId;

  const CourseImage({required this.id, required this.url, this.publicId});

  factory CourseImage.fromJson(Map<String, dynamic> j) => CourseImage(
        id: (j['_id'] ?? '').toString(),
        url: j['url'] ?? '',
        publicId: j['publicId'],
      );
}

class CourseApiModel {
  final String id;
  final String title;
  final String description;
  final String? shortDescription;
  final double price;
  final String category;
  final String? thumbnail;
  final List<CourseImage> images;
  final List<String> features;
  final String? ageGroup;
  final String? duration;
  final String? level;
  final bool isPublished;
  final bool isFeatured;
  final bool gold;
  final DateTime? createdAt;

  const CourseApiModel({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    required this.price,
    required this.category,
    this.thumbnail,
    this.images = const [],
    this.features = const [],
    this.ageGroup,
    this.duration,
    this.level,
    this.isPublished = true,
    this.isFeatured = false,
    this.gold = false,
    this.createdAt,
  });

  factory CourseApiModel.fromJson(Map<String, dynamic> j) => CourseApiModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        shortDescription: j['shortDescription'],
        price: (j['price'] ?? 0).toDouble(),
        category: j['category'] ?? 'General',
        thumbnail: j['thumbnail'],
        images: (j['images'] as List? ?? [])
            .map((i) => CourseImage.fromJson(i as Map<String, dynamic>))
            .toList(),
        features: List<String>.from(j['features'] ?? []),
        ageGroup: j['ageGroup'],
        duration: j['duration'],
        level: j['level'],
        isPublished: j['isPublished'] ?? true,
        isFeatured: j['isFeatured'] ?? false,
        gold: j['gold'] ?? false,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'shortDescription': shortDescription,
        'price': price,
        'category': category,
        'thumbnail': thumbnail,
        'features': features,
        'ageGroup': ageGroup,
        'duration': duration,
        'level': level,
        'isPublished': isPublished,
        'isFeatured': isFeatured,
        'gold': gold,
      };
}
