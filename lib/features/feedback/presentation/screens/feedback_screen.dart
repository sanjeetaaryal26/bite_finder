import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:birdle/features/feedback/data/models/feedback_model.dart';
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
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackViewModel>().load(userId);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthViewModel>().currentUser!.id;
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeedbackViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

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
                      if (vm.submissions.isEmpty)
                        const EmptyState(message: 'No submissions yet')
                      else
                        ...vm.submissions.map(
                          (s) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.type.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.message,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.createdAt.split('T').first,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
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
