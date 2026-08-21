import 'package:flutter/material.dart';

import '../app/app_error_log.dart';
import 'petopia_theme.dart';
import "../l10n/petopia_text.dart";

void logUiError(String surface, Object error, StackTrace stackTrace) {
  AppErrorLog.instance.record(error, stackTrace, source: 'ui:$surface');
  debugPrint('Hearth & Tails $surface failed: $error\n$stackTrace');
}

class AppLoadError extends StatelessWidget {
  const AppLoadError({
    super.key,
    required this.title,
    this.message = '先歇一下再试，院子里的记录都还在。',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF7),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 34,
                      color: Color(0xFFE8A15C),
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B5445),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    AppText(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PetopiaColors.mutedText,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const AppText('再试一次'),
                      ),
                    ],
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
