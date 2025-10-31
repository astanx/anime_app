import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/history/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Mode? _mode;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final historyProvider = context.read<HistoryProvider>();
      final mode = await ModeStorage.getMode();
      await historyProvider.fetchHistory();

      setState(() {
        _mode = mode;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<HistoryProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore &&
        provider.hasMore) {
      provider.fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              if (_mode == null || _isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final history =
                  provider.history?.where((h) {
                    final canParse = int.tryParse(h.anime.id) != null;
                    return _mode == Mode.anilibria ? canParse : !canParse;
                  }).toList();

              if (history == null || history.isEmpty) {
                return Center(child: Text(l10n!.no_history_found));
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: history.length + (provider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == history.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return HistoryCard(historyData: history[index], mode: _mode!);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
