import 'package:birdle/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/core/services/local_storage_service.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final LocalStorageService storage;

  FeedbackRepositoryImpl(this.storage);

  List<FeedbackModel> _list() => storage.readFeedback().map(FeedbackModel.fromJson).toList();

  @override
  Future<void> addFeedback(FeedbackModel feedback) async {
    final list = _list();
    list.add(feedback);
    await storage.writeFeedback(list.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<FeedbackModel>> getFeedbackByUser(String userId) async {
    final list = _list().where((f) => f.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<FeedbackModel>> getAllFeedback() async {
    final list = _list();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    final list = _list();
    list.removeWhere((f) => f.id == feedbackId);
    await storage.writeFeedback(list.map((e) => e.toJson()).toList());
  }
}
