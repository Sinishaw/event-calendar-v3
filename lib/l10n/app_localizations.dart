import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_or.dart';
import 'app_localizations_te.dart';

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
    Locale('am'),
    Locale('en'),
    Locale('or'),
    Locale('te')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @dateConverter.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get dateConverter;

  /// No description provided for @nationalDays.
  ///
  /// In en, this message translates to:
  /// **'National Days'**
  String get nationalDays;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Event & Tasks'**
  String get plans;

  /// No description provided for @archives.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get archives;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policies'**
  String get termsAndConditions;

  /// No description provided for @shareUs.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareUs;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateUs;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @mn.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mn;

  /// No description provided for @tu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tu;

  /// No description provided for @wd.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wd;

  /// No description provided for @th.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get th;

  /// No description provided for @fr.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fr;

  /// No description provided for @st.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get st;

  /// No description provided for @sn.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sn;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @pagume.
  ///
  /// In en, this message translates to:
  /// **'Pagume'**
  String get pagume;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShort;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @pag.
  ///
  /// In en, this message translates to:
  /// **'Pag'**
  String get pag;

  /// No description provided for @newYear.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian New Year(Enkutatash)'**
  String get newYear;

  /// No description provided for @meskel.
  ///
  /// In en, this message translates to:
  /// **'Finding of the True Cross(Meskel)'**
  String get meskel;

  /// No description provided for @timket.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Epiphany(Timket)'**
  String get timket;

  /// No description provided for @genna.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Christmass Day'**
  String get genna;

  /// No description provided for @siklet.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Good Friday'**
  String get siklet;

  /// No description provided for @fasika.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Easter'**
  String get fasika;

  /// No description provided for @adwa.
  ///
  /// In en, this message translates to:
  /// **'Victory of Adwa'**
  String get adwa;

  /// No description provided for @arbegnoch.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Patriots Victory Day'**
  String get arbegnoch;

  /// No description provided for @labaderoch.
  ///
  /// In en, this message translates to:
  /// **'Labour Day'**
  String get labaderoch;

  /// No description provided for @ginbot20.
  ///
  /// In en, this message translates to:
  /// **'Derg Downfall Day'**
  String get ginbot20;

  /// No description provided for @eidAlFitur.
  ///
  /// In en, this message translates to:
  /// **'Eid ul-Fitr'**
  String get eidAlFitur;

  /// No description provided for @mewlid.
  ///
  /// In en, this message translates to:
  /// **'Prophet\'s Birthday(Mewlid)'**
  String get mewlid;

  /// No description provided for @eidAlAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid ul-Adha(Arefa)'**
  String get eidAlAdha;

  /// No description provided for @ethiopia.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get ethiopia;

  /// No description provided for @fromEthiopia.
  ///
  /// In en, this message translates to:
  /// **'From Ethiopia'**
  String get fromEthiopia;

  /// No description provided for @ethiopian.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian'**
  String get ethiopian;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @input.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get input;

  /// No description provided for @convertAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Convert and return'**
  String get convertAndReturn;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @future.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get future;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @addNewEventOrTask.
  ///
  /// In en, this message translates to:
  /// **'Add New Event or Task'**
  String get addNewEventOrTask;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is Required'**
  String get titleRequired;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @pickADate.
  ///
  /// In en, this message translates to:
  /// **'Pick a Date'**
  String get pickADate;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @pickATime.
  ///
  /// In en, this message translates to:
  /// **'Pick a Time'**
  String get pickATime;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get afternoon;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @importanceTag.
  ///
  /// In en, this message translates to:
  /// **'Importance Tag'**
  String get importanceTag;

  /// No description provided for @importanceTagPicker.
  ///
  /// In en, this message translates to:
  /// **'Importance Tag Picker'**
  String get importanceTagPicker;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// No description provided for @veryImportant.
  ///
  /// In en, this message translates to:
  /// **'Very Important'**
  String get veryImportant;

  /// No description provided for @scheduleNotification.
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get scheduleNotification;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// No description provided for @fiveMinutesEarlier.
  ///
  /// In en, this message translates to:
  /// **'Five Minutes Earlier'**
  String get fiveMinutesEarlier;

  /// No description provided for @tenMinutesEarlier.
  ///
  /// In en, this message translates to:
  /// **'Ten Minutes Earlier'**
  String get tenMinutesEarlier;

  /// No description provided for @fifteenMinutesEarlier.
  ///
  /// In en, this message translates to:
  /// **'Fifteen Minutes Earlier'**
  String get fifteenMinutesEarlier;

  /// No description provided for @thirtyMinutesEarlier.
  ///
  /// In en, this message translates to:
  /// **'Thirty Minutes Earlier'**
  String get thirtyMinutesEarlier;

  /// No description provided for @repeatNotification.
  ///
  /// In en, this message translates to:
  /// **'Repeat Notification'**
  String get repeatNotification;

  /// No description provided for @noRepeat.
  ///
  /// In en, this message translates to:
  /// **'No Repeat'**
  String get noRepeat;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// No description provided for @noServiceProviderIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Service Provider is Available'**
  String get noServiceProviderIsAvailable;

  /// No description provided for @findServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Find Service Provider'**
  String get findServiceProvider;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @generalTerms.
  ///
  /// In en, this message translates to:
  /// **'General Terms'**
  String get generalTerms;

  /// No description provided for @serviceProviderTerms.
  ///
  /// In en, this message translates to:
  /// **'Service Provider Terms'**
  String get serviceProviderTerms;

  /// No description provided for @thisContentIsNotDownloadedYet.
  ///
  /// In en, this message translates to:
  /// **'This content is not downloaded yet'**
  String get thisContentIsNotDownloadedYet;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @numberFormat.
  ///
  /// In en, this message translates to:
  /// **'Number Format'**
  String get numberFormat;

  /// No description provided for @weekStartDay.
  ///
  /// In en, this message translates to:
  /// **'Week Start Day'**
  String get weekStartDay;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @restartIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart is Required'**
  String get restartIsRequired;

  /// No description provided for @companyChannel.
  ///
  /// In en, this message translates to:
  /// **'Company Channel'**
  String get companyChannel;

  /// No description provided for @interestChannel.
  ///
  /// In en, this message translates to:
  /// **'Your Interests Channel'**
  String get interestChannel;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @noCompany.
  ///
  /// In en, this message translates to:
  /// **'No Company'**
  String get noCompany;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @noInterestIsSelected.
  ///
  /// In en, this message translates to:
  /// **'No Interest is Selected'**
  String get noInterestIsSelected;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @alarmIsSetFor.
  ///
  /// In en, this message translates to:
  /// **'Alarm is Set For'**
  String get alarmIsSetFor;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @noDocumentIsFound.
  ///
  /// In en, this message translates to:
  /// **'No Document is Found'**
  String get noDocumentIsFound;

  /// No description provided for @noEventIsFound.
  ///
  /// In en, this message translates to:
  /// **'No Event is Found'**
  String get noEventIsFound;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @areYouSureYouWantToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get areYouSureYouWantToDelete;

  /// No description provided for @tapAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Tap again to exit'**
  String get tapAgainToExit;

  /// No description provided for @pleaseSelectFutureDateOnly.
  ///
  /// In en, this message translates to:
  /// **'Please select Future date only'**
  String get pleaseSelectFutureDateOnly;

  /// No description provided for @eventTitleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Event Title is Required'**
  String get eventTitleIsRequired;

  /// No description provided for @applicationServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Application Service Provider'**
  String get applicationServiceProvider;

  /// No description provided for @applicationServiceProviderNotice.
  ///
  /// In en, this message translates to:
  /// **'By selecting the app provider, you are getting closer to the selected company, you will be able to access a wide range of related and relevant information. Remember to read the rules and conditions of your chosen organization properly.'**
  String get applicationServiceProviderNotice;

  /// No description provided for @topicNotice.
  ///
  /// In en, this message translates to:
  /// **'Select at least three that are relevant to your needs: You may be able to access events related to your needs as well as related issues.'**
  String get topicNotice;

  /// No description provided for @thirteenMonthsOfSunshine.
  ///
  /// In en, this message translates to:
  /// **'Ethi♡pia, 13 Months of Sunshine'**
  String get thirteenMonthsOfSunshine;

  /// No description provided for @clickHereToOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Click here to open source'**
  String get clickHereToOpenSource;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'or', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
    case 'or': return AppLocalizationsOr();
    case 'te': return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
