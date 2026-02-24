import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthGradientShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

  const AuthGradientShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF4DDE0),
        alignment: Alignment.center,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF980E12),
                      Color(0xFFB1363B),
                      Color(0xFFE6BCC1),
                    ],
                    stops: [0.0, 0.48, 1.0],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBack)
                      IconButton(
                        onPressed: onBack ?? () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                      ),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFFF6E8E9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
