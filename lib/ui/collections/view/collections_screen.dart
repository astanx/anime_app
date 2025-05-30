import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/l10n/collection_localization.dart';
import 'package:anime_app/ui/collections/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final ScrollController _scrollController = ScrollController();
  CollectionType _type = CollectionType.planned;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CollectionsProvider>(context, listen: false);
    provider.fetchCollection(_type);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.my_collections),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CollectionsProvider>(
            builder: (context, provider, _) {
              final collections = provider.collections;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CollectionType>(
                        isExpanded: true,
                        value: _type,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        onChanged: (CollectionType? newType) async {
                          if (newType != null) {
                            setState(() {
                              _type = newType;
                            });
                            await provider.fetchCollection(newType);
                          }
                        },
                        items:
                            CollectionType.values.map((CollectionType type) {
                              return DropdownMenuItem<CollectionType>(
                                value: type,
                                child: Text(
                                  type.localizedName(context),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child:
                        collections[_type] == null
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(l10n.loading_your_collection),
                                ],
                              ),
                            )
                            : collections[_type]!.data.isEmpty &&
                                !provider.isLoadingMore(_type)
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.no_collection,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : ListView.separated(
                              controller: _scrollController,
                              itemCount:
                                  collections[_type]!.data.length +
                                  (provider.hasMore(_type) ? 1 : 0),
                              separatorBuilder:
                                  (context, index) =>
                                      const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index < collections[_type]!.data.length) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CollectionCard(
                                      anime: collections[_type]!.data[index],
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
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
        ),
      ),
    );
  }
}
