import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/menu/bottom_navigation.dart';
import 'package:event_calendar_v2/menu/side_menu.dart';
import 'package:event_calendar_v2/pages.dart';
import 'package:event_calendar_v2/services/home_widget/home_widget_service.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'common/constants.dart';
import 'common/globals.dart';
import 'configs/theme/theme_model.dart';
import 'firebase/cloudMessaging/FcmHandler.dart';
import 'firebase/firestore/firestore.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;
import 'screens/company/models/company_content_model.dart';
import 'screens/events/models/notification_payload.dart';
import 'screens/topic/model/topic_model.dart';
import 'utils/firebase_logger.dart';
import 'utils/utilities.dart';
import 'screens/company/widgets/content_detail_page.dart';
import 'screens/plans/user_event_page.dart';
import 'screens/splash/splash_screen.dart';

const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');

/// True if [uri] is a home-screen widget deep link (`…/day` or `…/add`). iOS
/// delivers these via Flutter's route channel; the host is dropped, so the
/// action lives in the first path segment.
bool _isWidgetLink(Uri? uri) {
  if (uri == null) return false;
  final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
  return seg == 'day' || seg == 'add';
}

/// The page a widget deep link opens: `add` → the add-event form (defaults to
/// today); `day` → the day view on `d`, scrolled to `t` (minutes-of-day).
Route<dynamic> _widgetPageRoute(Uri uri) {
  if (uri.pathSegments.first == 'add') {
    return MaterialPageRoute(builder: (_) => const UserEventPage());
  }
  final d = DateTime.tryParse(uri.queryParameters['d'] ?? '');
  final t = int.tryParse(uri.queryParameters['t'] ?? '');
  return MaterialPageRoute(
    builder: (_) => UserEventPage(
      initialShowDayView: true,
      initialDayViewDate: d ?? DateTime.now(),
      initialDayViewScrollMinutes: t,
    ),
  );
}

FirebaseOptions get firebaseOptions => environment == 'prod'
    ? prod.DefaultFirebaseOptions.currentPlatform
    : dev.DefaultFirebaseOptions.currentPlatform;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("----- Forground Notification Received.");
  await Firebase.initializeApp(options: firebaseOptions);
  Globals.prefs ??= await SharedPreferences.getInstance();
  await NotificationService().initNotifications();
  try {
    Utility.cacheUserRelatedContents();
    bool isNotificationAllowed = Utility.isUserAllowNotificationChannel(message.data["topic"]);

    ///Show notification right away
    if (isNotificationAllowed) {
      bool notifyUser = message.data["notifyUser"] == "true" ? true : false;
      if (notifyUser) {
        NotificationService().showNotification(
            title: message.data["title"],
            body: message.data["body"],
            payload: _contentTapPayload(message),
            notificationSource: message.data["topic"]);
      }
    }
  } catch (e) {
    debugPrint("------ error fcm background handler");
    debugPrint(e.toString());
  }
  try {
    bool markOnCalendar = message.data["markOnCalendar"] == "true" ? true : false;
    if (markOnCalendar) _saveLocalNotification(message);
  } catch (e) {
    debugPrint("------ Error saving payload to local notification!");
  }
}

/// Builds the tap payload for the immediate "notify" notification so tapping it
/// (from background/terminated) opens the content's detail page instead of home.
/// Carries [contentId] + contentSource so `_handleNotificationTap` can route it.
String _contentTapPayload(RemoteMessage message) {
  final DateTime now = DateTime.now();
  final NotificationPayload payload = NotificationPayload(
    id: NotificationService.calendarMarkId(message.data["id"] ?? ""),
    contentId: message.data["id"],
    title: message.data["title"],
    body: message.data["body"],
    createdDateTime: now,
    scheduledDateTime: now,
    eventTagOption: EventTagOption.values.firstWhere(
        (e) => e.toString().split(".").last.toLowerCase() == message.data["tagColor"],
        orElse: () => EventTagOption.regular),
    scheduleOption: NotificationScheduleOption.onTime,
    repeatOption: NotificationRepeatOption.noRecurrence,
    contentSource: ContentSource.values.firstWhere(
        (e) => e.toString().split(".").last == message.data["contentSource"],
        orElse: () => ContentSource.CompanyEvent),
    topic: message.data["topic"],
    icon: message.data["logo"],
    visible: "true",
  );
  return json.encode(payload);
}

_saveLocalNotification(RemoteMessage message) {
  try {
    final String? markDateStr = message.data["markDate"];
    if (markDateStr == null) return;
    final DateTime scheduleDate = DateTime.parse(markDateStr).toLocal();

    NotificationService().scheduleCalendarMark(
      id: message.data["id"] ?? "",
      markDate: scheduleDate,
      title: message.data["title"],
      body: message.data["body"],
      tagColor: message.data["tagColor"],
      // The FCM payload sends the age restriction under "ageRestriction", not "age".
      ageRestriction: message.data["ageRestriction"],
      topic: message.data["topic"],
      icon: message.data["logo"],
      contentSource: ContentSource.values.firstWhere(
          (e) => e.toString().split(".").last == message.data["contentSource"],
          orElse: () => ContentSource.CompanyEvent),
      repeatOption: NotificationRepeatOption.values.firstWhere(
          (e) => e.toString().split(".").last == message.data["repeatOption"],
          orElse: () => NotificationRepeatOption.noRecurrence),
    );
  } catch (e) {
    debugPrint("------ Error setting notification from fcm payload!");
    debugPrint(e.toString());
    throw Exception(e);
  }
}

///Register user
Future<void> registerUserIdInFirestore() async {
  String? token = Globals.prefs!.getString("fcm_token");
  debugPrint("------ FCM-TOKEN value ...$token");
  FieldValue timestamp = FieldValue.serverTimestamp();
  if (token == null) {
    FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 5)).then((value) {
      var arr = value!.split(":");
      FirebaseFirestore.instance
          .collection("Users")
          .doc(arr[0])
          .set({"id": arr[0], "token": value, "createdTimestamp": timestamp}).then((_value) {
        debugPrint("------ User is created in firestore ...");
        Globals.prefs!.setString("fcm_token", value);
        debugPrint("------ FCM-TOKEN value ...${Globals.prefs!.getString("fcm_token")}");

        ///All users can be reached with this subscription topic channel for update notice and other messages
        FcmHandler.subscribeUserToTopic(Constants.PublicSubscriptionTopic);
        CloudFireStore().registerCompanyCount(increaseBy: 1);
      });
      return;
    }).catchError((dynamic error) {
      debugPrint("------ Error registering userId/getToken: $error");
    });
  }
}

Future<String> initializeApp() async {
  try {
    debugPrint("------ 1");
    await Firebase.initializeApp(options: firebaseOptions).timeout(const Duration(seconds: 5)).then((value) async {
      debugPrint("------ 2");
      await Globals.initGlobals();
      debugPrint("------ 3");
      registerUserIdInFirestore();
      debugPrint("------ 4");
      await NotificationService().initNotifications();
      debugPrint("------ 5");
      debugPrint("------ 6");
    }).onError((dynamic error, stackTrace) async {
      await Globals.initGlobals();
    });
    return "true";
  } catch (e) {
    return "false";

    ///TODO: Returning false value causes the app to stack on splash page. At this stage the app tried and
    ///fail to initialize firebase. But returning true will still help the app to work on next if condition
    // return "true";
  }
}

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Date widget: recompute today's strings from cached data, then reschedule
    // the next midnight refresh so it keeps rolling over day after day.
    if (taskName == HomeWidgetService.midnightTaskName) {
      WidgetsFlutterBinding.ensureInitialized();
      await HomeWidgetService.updateDateWidget();
      await HomeWidgetService.scheduleMidnightRefresh();
      return true;
    }

    final now = DateTime.now();
    final results = await Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]);
    return !results.contains(false);
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  // ignore: avoid_print
  print(data);

  if (data?.host == 'titleclicked') {
    final greetings = ['Hello', 'Hallo', 'Bonjour', 'Hola', 'Ciao', '哈洛', '안녕하세요', 'xin chào'];
    final selectedGreeting = greetings[Random().nextInt(greetings.length)];

    await HomeWidget.saveWidgetData<String>('title', selectedGreeting);
    await HomeWidget.updateWidget(name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  NotificationService().initNotifications();
  Globals.prefs = await SharedPreferences.getInstance();
  Globals.initCompanySettingFromLocalIfAny();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  /// Root navigator, used to open widget deep links from the app-level observer.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // App Group shared between the app and the iOS WidgetKit extension; must
    // match the group id in Runner.entitlements and DateWidget.entitlements.
    HomeWidget.setAppGroupId('group.com.example.eventCalendarV2');
    HomeWidget.registerBackgroundCallback(backgroundCallback);
    // Observe route pushes so we can intercept iOS widget deep links before
    // Flutter's default handler turns them into a (missing) named route. Added
    // here (parent of MaterialApp) so this observer runs before WidgetsApp's.
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// iOS delivers home-screen widget taps (eventcalendarwidget://open/day|add)
  /// through the route channel. Swallow them here (return true) and apply them
  /// via [HomeWidgetService.pendingWidgetUri] so they never get pushed as a
  /// route on top of the splash (which the splash would then replace with home).
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    if (!_isWidgetLink(uri)) return false;
    HomeWidgetService.pendingWidgetUri = uri;
    // If the UI is ready (warm tap), open it now; otherwise ContainerPage
    // consumes the pending link once it mounts (cold start, after the splash).
    if (HomeWidgetService.appReady) {
      final pending = HomeWidgetService.pendingWidgetUri;
      HomeWidgetService.pendingWidgetUri = null;
      if (pending != null) App.navigatorKey.currentState?.push(_widgetPageRoute(pending));
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future _sendData() async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('title', _titleController.text),
        HomeWidget.saveWidgetData<String>('message', _messageController.text),
        HomeWidget.renderFlutterWidget(
          Icon(
            Icons.flutter_dash,
            size: 200,
          ),
          logicalSize: Size(200, 200),
          key: 'dashIcon',
        ),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future _updateWidget() async {
    try {
      return HomeWidget.updateWidget(name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  Future _loadData() async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('title', defaultValue: 'Default Title')
            .then((value) => _titleController.text = value ?? ''),
        HomeWidget.getWidgetData<String>('message', defaultValue: 'Default Message')
            .then((value) => _messageController.text = value ?? ''),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Getting Data. $exception');
    }
  }

  Future<void> _sendAndUpdate() async {
    await _sendData();
    await _updateWidget();
  }

  void _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask('1', 'widgetBackgroundUpdate', frequency: Duration(minutes: 15));
  }

  void _stopBackgroundUpdate() {
    Workmanager().cancelByUniqueName('1');
  }

  @override
  Widget build(BuildContext context) {
    ///TODO: Commented
    // debugPrint("------ Loggin...");
    // FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LanguageChangeProvider>(create: (_) => LanguageChangeProvider()),
      ],
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageChangeProvider>(context);

        return MaterialApp(
          onGenerateTitle: (context) {
            ///Update global static variables and avoid asking user to restart app
            Globals.context = context;
            MonthGlobals.reinitializeGlobalsWithSelectedLanguage(context);
            Globals.reinitializeGlobalsWithSelectedLanguage(context);
            Globals.initMonthsImage();
            return AppLocalizations.of(context)!.thirteenMonthsOfSunshine;
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: themeProvider.currentTheme,
          locale: languageProvider.getCurrentLocale(),
          navigatorKey: App.navigatorKey,
          navigatorObservers: <NavigatorObserver>[App.observer],
          // Widget deep links are intercepted in _AppState.didPushRouteInformation
          // and applied via pendingWidgetUri (see there), so the app just boots
          // normally at the splash here.
          home: const SplashScreen(),
        );
      },
    );
  }
}

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _launchDetailsConsumed = false;

  Color? iconsColor;
  // bool _notificationsEnabled = false;

  isAndroidGranted() async {
    bool isNotificationEnabled = await NotificationService().isAndroidPermissionGranted();
    if (!isNotificationEnabled) {
      setState(
        () {
          //Not implemented
          /// TODO: Notify user that the notification is not enabled
        },
      );
    }
  }

  ///TODO: Use function in utility file if possible. Utility.cacheUserRelatedContents();
  _cacheUserRelatedContents() async {
    List<String> topics = [];
    var company = Globals.prefs!.getString(Constants.CompanyPreference);
    topics.clear();
    if (company != null) {
      topics.add(company);
    } else {
      company = Constants.DefaultCompany;
    }
    List<Topic> followedTopics = Topic.getUserSubscribedTopics();
    for (var element in followedTopics) {
      var data = element.name!.split("~");
      topics.add(data[0]);
    }
    debugPrint("------ Topic Subscriptions: $topics");
    CompanyContentModel().cacheUserRelatedContents(company, topics);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('-----------Main: Initializing');
    NotificationService().requestPermissions();
    FcmHandler(context);
    _cacheUserRelatedContents();

    // Foreground taps — stream delivers while app is active
    NotificationService.selectNotificationStream.stream.listen((payload) {
      if (!mounted || payload == null) return;
      NotificationService.pendingTapPayload = null;
      _handleNotificationTap(payload);
    });

    // Terminated + fast-resume taps — check on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingNotification());

    // Keep the Android home-screen date widget current (localized names are
    // available now that the app is running).
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDateWidget());

    // The UI is now ready, so widget deep links can be opened directly.
    HomeWidgetService.appReady = true;

    // Home-screen widget taps.
    //  • Android: delivered here via home_widget's widgetClicked / launch.
    //  • iOS (scene delegate): delivered via the route channel and captured in
    //    _AppState.didPushRouteInformation → pendingWidgetUri, consumed below
    //    (cold start, after the splash).
    HomeWidget.widgetClicked.listen((uri) {
      if (mounted && uri != null) _handleWidgetUri(uri);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (mounted && uri != null) _handleWidgetUri(uri);
      });
      // Cold-start widget link stashed by _AppState before ContainerPage mounted.
      final pending = HomeWidgetService.pendingWidgetUri;
      if (pending != null) {
        HomeWidgetService.pendingWidgetUri = null;
        _handleWidgetUri(pending);
      }
    });
  }

  /// Routes a tap coming from the iOS/Android home-screen widget. The action is
  /// the URI host (Android: `eventcalendarwidget://day|add`) or, when iOS routes
  /// it and drops the host, the first path segment (`…/day|add`).
  void _handleWidgetUri(Uri uri) {
    if (!mounted) return;
    final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final action = (uri.host == 'add' || uri.host == 'day') ? uri.host : seg;
    if (action == 'add') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserEventPage()),
      );
    } else if (action == 'day') {
      final parsed = DateTime.tryParse(uri.queryParameters['d'] ?? '');
      final t = int.tryParse(uri.queryParameters['t'] ?? '');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => UserEventPage(
          initialShowDayView: true,
          initialDayViewDate: parsed ?? DateTime.now(),
          initialDayViewScrollMinutes: t,
        ),
      ));
    }
  }

  @override
  void dispose() {
    HomeWidgetService.appReady = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // iOS: onDidReceiveNotificationResponse fires just before resumed; by the time
    // this callback fires, pendingTapPayload is already set.
    if (state == AppLifecycleState.resumed) {
      _checkPendingNotification();
      _refreshDateWidget();
    }
  }

  /// Refresh the Android date widget with full localization + schedule the next
  /// midnight rollover. Android-only; no-op elsewhere.
  Future<void> _refreshDateWidget() => HomeWidgetService.refreshNow();

  void _checkPendingNotification() {
    // Primary path: set by onDidReceiveNotificationResponse (foreground + background + terminated)
    final pending = NotificationService.pendingTapPayload;
    if (pending != null && mounted) {
      NotificationService.pendingTapPayload = null;
      _handleNotificationTap(pending);
      return;
    }
    // Fallback: iOS terminated state via getNotificationAppLaunchDetails()
    if (!_launchDetailsConsumed) {
      final details = Globals.notificationAppLaunchDetails;
      if (details?.didNotificationLaunchApp == true) {
        _launchDetailsConsumed = true;
        final payload = details!.notificationResponse?.payload;
        if (payload != null && mounted) _handleNotificationTap(payload);
      }
    }
  }

  void _handleNotificationTap(String rawPayload) {
    try {
      final map = jsonDecode(rawPayload) as Map<String, dynamic>;
      final p = NotificationPayload.fromJson(map);

      switch (p.contentSource) {
        case ContentSource.UserTask:
          final gcDate = (p.gY != null && p.gM != null && p.gD != null)
              ? DateTime(p.gY!, p.gM!, p.gD!)
              : p.scheduledDateTime ?? DateTime.now();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => UserEventPage(
              initialShowDayView: true,
              initialDayViewDate: gcDate,
              initialDayViewEvent: p,
            ),
          ));
          break;
        case ContentSource.CompanyEvent:
        case ContentSource.TopicEvent:
        case ContentSource.NationalEvent:
          _openContentDetail(p);
          break;
        default:
          _goHome();
      }
    } catch (_) {
      _goHome();
    }
  }

  void _openContentDetail(NotificationPayload p) {
    ContentDetailPage.openFromPayload(context, p, onNotFound: _goHome);
  }

  void _goHome() => setState(() => Globals.displayingIndex = 0);

  @override
  void didChangeDependencies() {
    iconsColor = Theme.of(context).primaryColor;
    _getDeviceSize();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: false,
      body: Center(child: _getSelectedWidget(Globals.displayingIndex)),
      drawer: Globals.setting.leftMenu!
          ? SideMenu(
              scaffoldKey: _scaffoldKey,
              isLeftMenu: Globals.setting.leftMenu!,
              callback: _getSelectedWidget,
            )
          : null,
      endDrawer: !Globals.setting.leftMenu!
          ? SideMenu(
              scaffoldKey: _scaffoldKey,
              isLeftMenu: Globals.setting.leftMenu!,
              callback: _getSelectedWidget,
            )
          : null,
      bottomNavigationBar: BottomNavigation(callback: _onItemTapped),
    );
  }

  _getSelectedWidget(int index) {
    FirebaseLogger.logGlobalScreenView(index);
    FirebaseLogger.logCompanyScreenView(index);
    _onItemTapped(index);
    return Pages.screenViewOptions[index];
  }

  _onItemTapped(int index) {
    if (_scaffoldKey.currentState == null) {
      setState(() {});
      return;
    }

    if (_scaffoldKey.currentState != null &&
        (_scaffoldKey.currentState!.isDrawerOpen || _scaffoldKey.currentState!.isEndDrawerOpen)) {
      Navigator.pop(context);
    }

    index == 4
        ? Globals.setting.leftMenu!
            ? _scaffoldKey.currentState!.openDrawer()
            : _scaffoldKey.currentState!.openEndDrawer()
        : setState(() {
            Globals.selectedIndex = index < 4 ? index : 4;
            Globals.displayingIndex = index;
          });
  }

  _getDeviceSize() {
    Globals.deviceWidth = MediaQuery.of(context).size.width;
    Globals.deviceHeight = MediaQuery.of(context).size.height;
    Globals.deviceDip = MediaQuery.of(context).devicePixelRatio;
  }
}
