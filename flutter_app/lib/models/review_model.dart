class ReviewModel {
  final String id;
  final String voiceOfTrustId;
  final String? voiceOfTrustTitle;
  final String customerName;
  final String message;
  final int? rating;
  final String? adminReply;
  final DateTime? repliedAt;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.voiceOfTrustId,
    this.voiceOfTrustTitle,
    required this.customerName,
    required this.message,
    this.rating,
    this.adminReply,
    this.repliedAt,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final vot = j['voiceOfTrust'];
    return ReviewModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      voiceOfTrustId: vot is Map ? (vot['_id'] ?? '').toString() : (vot ?? '').toString(),
      voiceOfTrustTitle: vot is Map ? vot['title'] as String? : null,
      customerName: j['customerName'] ?? '',
      message: j['message'] ?? '',
      rating: (j['rating'] as num?)?.toInt(),
      adminReply: j['adminReply'],
      repliedAt: j['repliedAt'] != null ? DateTime.tryParse(j['repliedAt'].toString()) : null,
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'].toString()) : null,
    );
  }
}
