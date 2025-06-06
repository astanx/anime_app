import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @prev_episode.
  ///
  /// In en, this message translates to:
  /// **'Previous episode'**
  String get prev_episode;

  /// No description provided for @next_episode.
  ///
  /// In en, this message translates to:
  /// **'Next episode'**
  String get next_episode;

  /// No description provided for @skip_opening.
  ///
  /// In en, this message translates to:
  /// **'Skip opening'**
  String get skip_opening;

  /// No description provided for @episode_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No episodes} =1{1 episode} other{{count} episodes}}'**
  String episode_count(num count);

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @movie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get movie;

  /// No description provided for @series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// No description provided for @franchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get franchise;

  /// No description provided for @torrent.
  ///
  /// In en, this message translates to:
  /// **'Torrent'**
  String get torrent;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @url_error.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL'**
  String get url_error;

  /// No description provided for @collection_planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get collection_planned;

  /// No description provided for @collection_watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get collection_watched;

  /// No description provided for @collection_watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get collection_watching;

  /// No description provided for @collection_postponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get collection_postponed;

  /// No description provided for @collection_abandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get collection_abandoned;

  /// No description provided for @kodik_player.
  ///
  /// In en, this message translates to:
  /// **'Kodik player'**
  String get kodik_player;

  /// No description provided for @episode.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Episode} other{Episodes}}'**
  String episode(num count);

  /// No description provided for @anime_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter anime title'**
  String get anime_search_placeholder;

  /// No description provided for @no_anime_found.
  ///
  /// In en, this message translates to:
  /// **'No anime found{query}.'**
  String no_anime_found(Object query);

  /// No description provided for @my_collections.
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get my_collections;

  /// No description provided for @loading_your_collection.
  ///
  /// In en, this message translates to:
  /// **'Loading your collection...'**
  String get loading_your_collection;

  /// No description provided for @no_collection.
  ///
  /// In en, this message translates to:
  /// **'No items found in this collection'**
  String get no_collection;

  /// No description provided for @no_favourites_found.
  ///
  /// In en, this message translates to:
  /// **'No favourites found.'**
  String get no_favourites_found;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favoruties'**
  String get favourites;

  /// No description provided for @no_history_found.
  ///
  /// In en, this message translates to:
  /// **'No history found.'**
  String get no_history_found;

  /// No description provided for @last_watched_episode.
  ///
  /// In en, this message translates to:
  /// **'Last watched episode: {last_watched}'**
  String last_watched_episode(Object last_watched);

  /// No description provided for @continue_with_kodik.
  ///
  /// In en, this message translates to:
  /// **'Continue with Kodik'**
  String get continue_with_kodik;

  /// No description provided for @continue_with_episode.
  ///
  /// In en, this message translates to:
  /// **'Continue with episode {episode} '**
  String continue_with_episode(Object episode);

  /// No description provided for @continue_watching_episode.
  ///
  /// In en, this message translates to:
  /// **'Continue watching episode {episode} '**
  String continue_watching_episode(Object episode);

  /// No description provided for @no_new_episodes.
  ///
  /// In en, this message translates to:
  /// **'There are no new episodes :('**
  String get no_new_episodes;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login with Anilibria'**
  String get login_title;

  /// No description provided for @login_label.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_label;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @login_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your login'**
  String get login_empty_error;

  /// No description provided for @password_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get password_empty_error;

  /// No description provided for @submit_button.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit_button;

  /// No description provided for @no_account_text.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account? '**
  String get no_account_text;

  /// No description provided for @register_text.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_text;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Oshavotik'**
  String get app_name;

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Watch anime'**
  String get app_title;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get this_week;

  /// No description provided for @latest_releases.
  ///
  /// In en, this message translates to:
  /// **'Latest releases'**
  String get latest_releases;

  /// No description provided for @search_anime.
  ///
  /// In en, this message translates to:
  /// **'Search anime'**
  String get search_anime;

  /// No description provided for @view_anime.
  ///
  /// In en, this message translates to:
  /// **'View anime'**
  String get view_anime;

  /// No description provided for @continue_watching_movie.
  ///
  /// In en, this message translates to:
  /// **'Continue watching movie'**
  String get continue_watching_movie;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
