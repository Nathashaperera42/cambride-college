import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/course_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/voice_of_trust_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/qualification_repository.dart';
import '../repositories/website_asset_repository.dart';
import '../repositories/course_review_repository.dart';
import 'auth_provider.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    ref.read(storageServiceProvider),
    // A 401 from an authenticated request means the session is no longer
    // valid (expired/invalid token, or the user was deleted) — force a
    // clean logout and prompt re-login instead of failing silently.
    onUnauthorized: () {
      ref.read(authProvider.notifier).logout();
      ref.read(pendingLoginModalProvider.notifier).state = true;
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(dioClientProvider));
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.read(dioClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(dioClientProvider));
});

final voiceOfTrustRepositoryProvider = Provider<VoiceOfTrustRepository>((ref) {
  return VoiceOfTrustRepository(ref.read(dioClientProvider));
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(dioClientProvider));
});

final qualificationRepositoryProvider = Provider<QualificationRepository>((ref) {
  return QualificationRepository(ref.read(dioClientProvider));
});

final websiteAssetRepositoryProvider = Provider<WebsiteAssetRepository>((ref) {
  return WebsiteAssetRepository(ref.read(dioClientProvider));
});

final courseReviewRepositoryProvider = Provider<CourseReviewRepository>((ref) {
  return CourseReviewRepository(ref.read(dioClientProvider));
});
