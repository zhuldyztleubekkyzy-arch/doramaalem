import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'kk': {
      // Auth
      'app_title': 'Дорама Әлем',
      'login': 'Кіру',
      'register': 'Тіркелу',
      'email': 'Электрондық пошта',
      'password': 'Құпия сөз',
      'confirm_password': 'Құпия сөзді растау',
      'display_name': 'Аты',
      'forgot_password': 'Құпия сөзді ұмыттыңыз ба?',
      'reset_password': 'Құпия сөзді қалпына келтіру',
      'sign_out': 'Шығу',
      'already_have_account': 'Аккаунтыңыз бар ма?',
      'dont_have_account': 'Аккаунтыңыз жоқ па?',
      
      // Home
      'home': 'Басты бет',
      'popular_doramas': 'Танымал дорамалар',
      'new_releases': 'Жаңа шығарылымдар',
      'my_favorites': 'Менің таңдауларым',
      'search': 'Іздеу',
      
      // Dorama
      'dorama_details': 'Дорама туралы',
      'episodes': 'Бөлімдер',
      'rating': 'Рейтинг',
      'year': 'Жыл',
      'genre': 'Жанр',
      'country': 'Ел',
      'description': 'Сипаттама',
      'watch_now': 'Қазір көру',
      'add_to_favorites': 'Таңдауларға қосу',
      'remove_from_favorites': 'Таңдаулардан алып тастау',
      
      // Errors
      'error': 'Қате',
      'error_loading': 'Жүктеу қатесі',
      'error_network': 'Желі қатесі',
      'try_again': 'Қайталап көріңіз',
      'invalid_email': 'Жарамсыз электрондық пошта',
      'weak_password': 'Құпия сөз тым әлсіз',
      'user_not_found': 'Пайдаланушы табылмады',
      'wrong_password': 'Қате құпия сөз',
      'email_already_in_use': 'Электрондық пошта қолданыста',
      
      // General
      'loading': 'Жүктелуде...',
      'cancel': 'Болдырмау',
      'save': 'Сақтау',
      'delete': 'Жою',
      'edit': 'Өңдеу',
      'back': 'Артқа',
      'next': 'Келесі',
      'previous': 'Алдыңғы',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for convenience
  String get appTitle => translate('app_title');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get displayName => translate('display_name');
  String get forgotPassword => translate('forgot_password');
  String get resetPassword => translate('reset_password');
  String get signOut => translate('sign_out');
  String get alreadyHaveAccount => translate('already_have_account');
  String get dontHaveAccount => translate('dont_have_account');
  String get home => translate('home');
  String get popularDoramas => translate('popular_doramas');
  String get newReleases => translate('new_releases');
  String get myFavorites => translate('my_favorites');
  String get search => translate('search');
  String get doramaDetails => translate('dorama_details');
  String get episodes => translate('episodes');
  String get rating => translate('rating');
  String get year => translate('year');
  String get genre => translate('genre');
  String get country => translate('country');
  String get description => translate('description');
  String get watchNow => translate('watch_now');
  String get addToFavorites => translate('add_to_favorites');
  String get removeFromFavorites => translate('remove_from_favorites');
  String get error => translate('error');
  String get errorLoading => translate('error_loading');
  String get errorNetwork => translate('error_network');
  String get tryAgain => translate('try_again');
  String get loading => translate('loading');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get back => translate('back');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['kk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

