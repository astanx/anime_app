// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get prev_episode => 'Предыдущий эпизод';

  @override
  String get next_episode => 'Следующий эпизод';

  @override
  String get skip_opening => 'Пропустить опенинг';

  @override
  String get skip_ending => 'Пропустить эндинг';

  @override
  String episode_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count эпизодов',
      one: '1 эпизод',
      zero: 'Нет эпизодов',
    );
    return '$_temp0';
  }

  @override
  String get ongoing => 'Выпускается';

  @override
  String get movie => 'Фильм';

  @override
  String get series => 'Сериал';

  @override
  String get franchise => 'Франшиза';

  @override
  String get torrent => 'Торрент';

  @override
  String get collection => 'Коллекция';

  @override
  String get url_error => 'Не удалось открыть ссылку';

  @override
  String get collection_planned => 'Планируется';

  @override
  String get collection_watched => 'Просмотрено';

  @override
  String get collection_watching => 'Смотрю';

  @override
  String get collection_postponed => 'Отложено';

  @override
  String get collection_abandoned => 'Брошено';

  @override
  String get kodik_player => 'Плеер Kodik';

  @override
  String episode(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Эпизоды',
      zero: 'Эпизод',
    );
    return '$_temp0';
  }

  @override
  String get anime_search_placeholder => 'Введите название аниме';

  @override
  String no_anime_found(Object query) {
    return 'Аниме с названием $query не найдено.';
  }

  @override
  String get my_collections => 'Мои коллекции';

  @override
  String get loading_your_collection => 'Загрузка вашей коллекции...';

  @override
  String get no_collection => 'В этой коллекции нет элементов';

  @override
  String get no_favourites_found => 'Избранное не найдено.';

  @override
  String get favourites => 'Избранное';

  @override
  String get no_history_found => 'История пуста.';

  @override
  String last_watched_episode(Object last_watched) {
    return 'Последний просмотренный эпизод: $last_watched';
  }

  @override
  String get continue_with_kodik => 'Продолжить с Kodik';

  @override
  String continue_with_episode(Object episode) {
    return 'Продолжить с эпизода $episode ';
  }

  @override
  String continue_watching_episode(Object episode) {
    return 'Продолжить просмотр эпизода $episode ';
  }

  @override
  String get no_new_episodes => 'Новых эпизодов нет';

  @override
  String get login_title => 'Войти через Anilibria';

  @override
  String get login_label => 'Логин';

  @override
  String get password_label => 'Пароль';

  @override
  String get login_empty_error => 'Пожалуйста, введите логин';

  @override
  String get password_empty_error => 'Пожалуйста, введите пароль';

  @override
  String get submit_button => 'Отправить';

  @override
  String get no_account_text => 'Нет аккаунта? ';

  @override
  String get register_text => 'Регистрация';

  @override
  String get home => 'Главная';

  @override
  String get search => 'Поиск';

  @override
  String get history => 'История';

  @override
  String get app_name => 'Oshavotik';

  @override
  String get app_title => 'Смотри аниме';

  @override
  String get exit => 'Выйти';

  @override
  String get genres => 'Жанры';

  @override
  String get this_week => 'На этой неделе';

  @override
  String get latest_releases => 'Последние релизы';

  @override
  String get search_anime => 'Поиск аниме';

  @override
  String get view_anime => 'Смотреть аниме';

  @override
  String get view_film => 'Смотреть фильм';

  @override
  String get continue_watching_movie => 'Продолжить просмотр фильма';

  @override
  String get select_payback_speed => 'Выбрать скорость воспроизведения';

  @override
  String get playback_speed => 'Скорость воспроизведения';

  @override
  String get quality => 'Качество';

  @override
  String get retry => 'Попробовать снова';

  @override
  String get server_unavailable => 'Сервер временно недоступен';
}
