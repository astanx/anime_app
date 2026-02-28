// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get prev_episode => 'Previous episode';

  @override
  String get next_episode => 'Next episode';

  @override
  String get skip_opening => 'Skip opening';

  @override
  String get skip_ending => 'Skip ending';

  @override
  String episode_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
      zero: 'No episodes',
    );
    return '$_temp0';
  }

  @override
  String get ongoing => 'Ongoing';

  @override
  String get movie => 'Movie';

  @override
  String get series => 'Series';

  @override
  String get franchise => 'Franchise';

  @override
  String get torrent => 'Torrent';

  @override
  String get collection => 'Collection';

  @override
  String get url_error => 'Could not launch URL';

  @override
  String get collection_planned => 'Planned';

  @override
  String get collection_watched => 'Watched';

  @override
  String get collection_watching => 'Watching';

  @override
  String get collection_postponed => 'Postponed';

  @override
  String get collection_abandoned => 'Abandoned';

  @override
  String get kodik_player => 'Kodik player';

  @override
  String episode(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Episodes',
      zero: 'Episode',
    );
    return '$_temp0';
  }

  @override
  String get anime_search_placeholder => 'Enter anime title';

  @override
  String no_anime_found(Object query) {
    return 'No anime found for $query.';
  }

  @override
  String get my_collections => 'My Collections';

  @override
  String get loading_your_collection => 'Loading your collection...';

  @override
  String get no_collection => 'No items found in this collection';

  @override
  String get no_favourites_found => 'No favourites found.';

  @override
  String get favourites => 'Favourites';

  @override
  String get no_history_found => 'No history found.';

  @override
  String last_watched_episode(Object last_watched) {
    return 'Last watched episode: $last_watched';
  }

  @override
  String get continue_with_kodik => 'Continue with Kodik';

  @override
  String continue_with_episode(Object episode) {
    return 'Continue with episode $episode ';
  }

  @override
  String continue_watching_episode(Object episode) {
    return 'Continue watching episode $episode ';
  }

  @override
  String get no_new_episodes => 'There are no new episodes';

  @override
  String get login_title => 'Login with Anilibria';

  @override
  String get login_label => 'Username';

  @override
  String get password_label => 'Password';

  @override
  String get login_empty_error => 'Please enter your login';

  @override
  String get password_empty_error => 'Please enter your password';

  @override
  String get submit_button => 'Submit';

  @override
  String get no_account_text => 'Don\'t have account? ';

  @override
  String get register_text => 'Register';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get history => 'History';

  @override
  String get app_name => 'Oshavotik';

  @override
  String get app_title => 'Watch anime';

  @override
  String get exit => 'Exit';

  @override
  String get genres => 'Genres';

  @override
  String get this_week => 'This week';

  @override
  String get latest_releases => 'Latest releases';

  @override
  String get search_anime => 'Search anime';

  @override
  String get view_anime => 'View anime';

  @override
  String get view_film => 'View film';

  @override
  String get continue_watching_movie => 'Continue watching movie';

  @override
  String get select_playback_speed => 'Select playback speed';

  @override
  String get playback_speed => 'Playback speed';

  @override
  String get quality => 'Quality';

  @override
  String get retry => 'Retry';

  @override
  String get server_unavailable => 'Server is currently unavailable';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get anilibria_mode => 'Continue with anilibria (Russian anime)';

  @override
  String get subtitle_mode => 'Continue with subtitles or dub';

  @override
  String get recommended => 'Recommended';

  @override
  String get anilibria => 'Anilibria';

  @override
  String get subtitle => 'Subtitle';

  @override
  String get choose_mode => 'Choose your preferred mode';

  @override
  String get you_can_change_later => 'You can change this later';

  @override
  String get disable_subtitles => 'Disable subtitles';

  @override
  String get subtitle_translate_language => 'Subtitle translate Language';

  @override
  String get dubbed => 'Dubbed';

  @override
  String get subbed => 'Subbed';

  @override
  String get new_sub_dub => 'New! Switch between Dub & Sub';

  @override
  String get episode_supports_both => 'This episode supports both versions.';
}
