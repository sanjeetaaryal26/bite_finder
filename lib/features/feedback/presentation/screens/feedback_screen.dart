import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/feedback/presentation/view_model/feedback_viewmodel.dart';
import 'package:birdle/core/widgets/state_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _restaurantId;
  FeedbackType _type = FeedbackType.feedback;
  bool _loaded = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) {
      return;
    }
    _loaded = true;
    final userId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackViewModel>().load(userId);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) {
      return;
    }
    final userId = user.id;
    final vm = context.read<FeedbackViewModel>();
    final ok = await vm.submit(
      userId: userId,
      restaurantId: _restaurantId,
      type: _type,
      message: _messageController.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      _messageController.clear();
      setState(() {
        _type = FeedbackType.feedback;
        _restaurantId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission stored')));
    } else if (vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.error!)));
    }
  }

  String _restaurantNameFor(FeedbackViewModel vm, String? restaurantId) {
    if (restaurantId == null || restaurantId.trim().isEmpty) {
      return 'General (No Restaurant)';
    }
    final match = vm.restaurants.where((r) => r.id == restaurantId).toList();
    if (match.isEmpty) {
      return 'Restaurant: $restaurantId';
    }
    return match.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeedbackViewModel>();
    final user = context.watch<AuthViewModel>().currentUser;
    if (user == null) {
      return const Scaffold(body: LoadingState());
    }
    final userId = user.id;
    final mergedSubmissions = [
      ...vm.submissions.map<_SubmissionItem>((f) => _SubmissionItem.feedback(f)),
      ...vm.reviews.map<_SubmissionItem>((r) => _SubmissionItem.review(r)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Complaint')),
      body: vm.isLoading && vm.restaurants.isEmpty
          ? const LoadingState()
          : vm.error != null && vm.restaurants.isEmpty
              ? ErrorState(message: vm.error!, onRetry: () => vm.load(userId))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submit', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String?>(
                              initialValue: _restaurantId,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Restaurant (optional)'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('General (No Restaurant)'),
                                ),
                                ...vm.restaurants.map(
                                  (r) => DropdownMenuItem<String?>(
                                    value: r.id,
                                    child: Text(
                                      r.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _restaurantId = v),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<FeedbackType>(
                              initialValue: _type,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: FeedbackType.values
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
                                  .toList(),
                              onChanged: (v) => setState(() => _type = v ?? FeedbackType.feedback),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              maxLength: 300,
                              decoration: const InputDecoration(labelText: 'Message'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Message is required';
                                if (v.trim().length < 10) return 'Write at least 10 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: vm.isLoading ? null : _submit,
                                child: const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 28),
                      Text('My Submissions', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (mergedSubmissions.isEmpty)
                        const EmptyState(message: 'No submissions yet')
                      else
                        ...mergedSubmissions.map(
                          (item) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.isReview) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 6),
                                        Text('${item.review!.rating}/5'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(item.message),
                                  const SizedBox(height: 6),
                                  Text(
                                    _restaurantNameFor(vm, item.restaurantId),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.createdAt.split('T').first,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (item.isReview && item.restaurantId != null) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push('/restaurant/${item.restaurantId}'),
                                        child: const Text('Open Restaurant'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _SubmissionItem {
  final FeedbackModel? feedback;
  final ReviewModel? review;

  _SubmissionItem.feedback(this.feedback) : review = null;
  _SubmissionItem.review(this.review) : feedback = null;

  bool get isReview => review != null;
  String get createdAt => isReview ? review!.createdAt : feedback!.createdAt;
  String? get restaurantId => isReview ? review!.restaurantId : feedback!.restaurantId;
  String get message => isReview ? review!.comment : feedback!.message;
  String get title {
    if (isReview) return 'REVIEW';
    return feedback!.type.name.toUpperCase();
  }
}
