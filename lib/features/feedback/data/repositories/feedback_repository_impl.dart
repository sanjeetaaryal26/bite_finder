import 'package:birdle/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/core/services/local_storage_service.dart';
import 'package:birdle/core/utils/app_logger.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final LocalStorageService storage;

  FeedbackRepositoryImpl(this.storage);

  List<FeedbackModel> _list() {
    final parsed = <FeedbackModel>[];
    final raw = storage.readFeedback();
    for (final item in raw) {
      try {
        parsed.add(FeedbackModel.fromJson(item));
      } catch (e, st) {
        AppLogger.error(e, st, context: 'FeedbackRepositoryImpl._list');
      }
    }
    return parsed;
  }

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
