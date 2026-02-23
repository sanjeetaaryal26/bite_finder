import '../../domain/repositories/feedback_repository.dart';
import '../models/feedback_model.dart';
import '../sources/local_storage_service.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final LocalStorageService storage;

  FeedbackRepositoryImpl(this.storage);

  @override
  Future<void> addFeedback(FeedbackModel feedback) async {
    final list = storage.readFeedback().map(FeedbackModel.fromJson).toList();
    list.add(feedback);
    await storage.writeFeedback(list.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<FeedbackModel>> getFeedbackByUser(String userId) async {
    final list = storage.readFeedback().map(FeedbackModel.fromJson).where((f) => f.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
