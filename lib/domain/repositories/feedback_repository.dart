import '../../data/models/feedback_model.dart';

abstract class FeedbackRepository {
  Future<void> addFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> getFeedbackByUser(String userId);
}
