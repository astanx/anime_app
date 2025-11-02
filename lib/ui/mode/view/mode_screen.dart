import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  final repository = UserRepository();
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final horizontalPadding = isWide ? 64.0 : 24.0;
            final verticalSpacing = isWide ? 24.0 : 16.0;
            if (isRegistering) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    l10n.choose_mode,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isWide ? 32 : null,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  Wrap(
                    spacing: verticalSpacing,
                    runSpacing: verticalSpacing,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: isWide ? 300 : double.infinity,
                        child: _buildModeCard(
                          context,
                          title: l10n.anilibria_mode,
                          icon: Icons.movie,
                          color: Colors.deepPurpleAccent,
                          onTap: () => _onPressed(Mode.anilibria),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 300 : double.infinity,
                        child: _buildModeCard(
                          context,
                          title: l10n.subtitle_mode,
                          icon: Icons.subtitles_rounded,
                          color: Colors.orangeAccent,
                          onTap: () => _onPressed(Mode.consumet),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    l10n.you_can_change_later,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: isWide ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPressed(Mode mode) async {
    if (isRegistering) return;
    setState(() {
      isRegistering = true;
    });
    await repository.registerDevice();
    await ModeStorage.saveMode(mode);
    if (mounted) {
      Navigator.of(context).pushNamed('/anime/list');
    }
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
