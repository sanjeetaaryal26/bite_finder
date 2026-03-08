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
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 600;
    final titleSize = width < 360 ? 30.0 : 34.0;
    final horizontalPadding = isMobile ? 18.0 : 16.0;
    final verticalPadding = isMobile ? 16.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final minHeight = (viewport.maxHeight - (verticalPadding * 2)).clamp(0.0, double.infinity);
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Align(
                    alignment: isMobile ? Alignment.topCenter : Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 420,
                        minHeight: isMobile ? minHeight : 0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                        decoration: isMobile
                            ? null
                            : BoxDecoration(
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
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
                                  fontSize: 14,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
