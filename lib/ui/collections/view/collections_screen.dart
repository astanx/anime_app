import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/l10n/collection_localization.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/core/ui/card/view/view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  Mode? mode;
  CollectionType _type = CollectionType.planned;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CollectionsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final m = await ModeStorage.getMode();
      await provider.fetchCollection(_type);
      setState(() {
        mode = m;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        provider.fetchNextPage(_type);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTypeChanged(int index) {
    final newType = CollectionType.values[index];
    if (newType != _type) {
      setState(() {
        _type = newType;
      });
      Provider.of<CollectionsProvider>(
        context,
        listen: false,
      ).fetchCollection(newType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (contex, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<CollectionsProvider>(
                builder: (context, provider, _) {
                  final collections = provider.collections;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: isWide ? 100 : 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: CollectionType.values.length,
                                itemBuilder: (context, index) {
                                  final type = CollectionType.values[index];
                                  final isSelected = type == _type;
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isWide ? 12 : 8,
                                      vertical: 8,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _onTypeChanged(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isWide ? 24 : 16,
                                          vertical: isWide ? 12 : 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient:
                                              isSelected
                                                  ? LinearGradient(
                                                    colors: [
                                                      theme.primaryColor,
                                                      theme.primaryColor
                                                          .withOpacity(0.8),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                  : null,
                                          color:
                                              isSelected
                                                  ? null
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border:
                                              isSelected
                                                  ? null
                                                  : Border.all(
                                                    color: theme.dividerColor,
                                                    width: 1,
                                                  ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            type.localizedName(context),
                                            style: TextStyle(
                                              fontSize: isWide ? 28 : 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            collections[_type] == null &&
                                    provider.hasFetched[_type] == false
                                ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.primaryColor,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.loading_your_collection,
                                        style: TextStyle(
                                          color: theme.hintColor,
                                          fontSize: isWide ? 36 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : collections[_type]!.isEmpty &&
                                    !provider.isLoadingMore(_type) &&
                                    provider.hasFetched[_type] == true
                                ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.folder_open_outlined,
                                        size: isWide ? 120 : 80,
                                        color: theme.hintColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.no_collection,
                                        style: TextStyle(
                                          color: theme.hintColor,
                                          fontSize: isWide ? 20 : 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.separated(
                                  controller: _scrollController,
                                  itemCount:
                                      collections[_type]!.length +
                                      (provider.hasMore(_type) ? 1 : 0),
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    if (index < collections[_type]!.length) {
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOut,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: SavedAnimeCard(
                                          anime: collections[_type]![index],
                                          isWide: isWide,
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  theme.primaryColor,
                                                ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
