import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/history/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await historyProvider.fetchHistory();
    });

    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              if (provider.history == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.history!.isEmpty) {
                return Center(child: Text(l10n!.no_history_found));
              }
              final history = provider.history!.reversed.toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return HistoryCard(anime: history[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
