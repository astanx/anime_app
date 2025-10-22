import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension CollectionTypeLocalization on CollectionType {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case CollectionType.planned:
        return l10n.collection_planned;
      case CollectionType.watched:
        return l10n.collection_watched;
      case CollectionType.watching:
        return l10n.collection_watching;
      case CollectionType.abandoned:
        return l10n.collection_abandoned;
    }
  }
}
