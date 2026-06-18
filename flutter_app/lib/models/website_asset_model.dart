class WebsiteAssetModel {
  final String id;
  final String assetType; // hero, banner, qualification, video
  final String? title;
  final String? imageUrl;
  final String? videoUrl;
  final String? redirectUrl;
  final String status; // active, inactive
  final int sortOrder;

  const WebsiteAssetModel({
    required this.id,
    required this.assetType,
    this.title,
    this.imageUrl,
    this.videoUrl,
    this.redirectUrl,
    this.status = 'active',
    this.sortOrder = 0,
  });

  bool get isActive => status == 'active';

  factory WebsiteAssetModel.fromJson(Map<String, dynamic> j) => WebsiteAssetModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        assetType: j['assetType'] ?? 'banner',
        title: j['title'],
        imageUrl: j['imageUrl'],
        videoUrl: j['videoUrl'],
        redirectUrl: j['redirectUrl'],
        status: j['status'] ?? 'active',
        sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
      );
}
