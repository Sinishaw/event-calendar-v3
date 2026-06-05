import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/firebase/dynamicLink/dynamicLink.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/menu/bottom_navigation.dart';
import 'package:event_calendar_v2/menu/side_menu.dart';
import 'package:event_calendar_v2/pages.dart';
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
import 'firebase_options.dart';
import 'screens/company/models/company_content_model.dart';
import 'screens/events/models/notification_payload.dart';
import 'screens/home/model/core_model.dart';
import 'screens/topic/model/topic_model.dart';
import 'shared/models/local_date_model.dart';
import 'utils/firebase_logger.dart';
import 'utils/utilities.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("----- Forground Notification Received.");
  await Firebase.initializeApp();
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
            payload: "",
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

_saveLocalNotification(RemoteMessage message) {
  try {
    int messageId = int.parse(message.data["id"]);
    DateTime scheduleDate = DateTime.parse(message.data["markDate"]).toLocal();
    LocalDate etScheduleDate =
        MonthModel.toEc(year: scheduleDate.year, month: scheduleDate.month, day: scheduleDate.day)!;

    NotificationPayload payload = NotificationPayload(
        id: messageId,
        title: message.data["title"],
        body: message.data["body"],
        createdDateTime: DateTime.now(),
        scheduledDateTime: scheduleDate,
        eventTagOption: EventTagOption.values
            .firstWhere((e) => e.toString().split(".").last.toLowerCase() == message.data["tagColor"]),
        repeatOption: NotificationRepeatOption.values
            .firstWhere((e) => e.toString().split(".").last == message.data["repeatOption"]),
        scheduleOption: NotificationScheduleOption.onTime,
        gD: scheduleDate.day,
        gM: scheduleDate.month,
        gY: scheduleDate.year,
        eD: etScheduleDate.day,
        eM: etScheduleDate.month,
        eY: etScheduleDate.year,
        weekday: scheduleDate.weekday,
        contentSource:
            ContentSource.values.firstWhere((e) => e.toString().split(".").last == message.data["contentSource"]),
        topic: message.data["topic"],
        age: int.parse(message.data["age"]),
        icon: message.data["logo"],
        visible: "true");

    String stringJsonPayload = json.encode(payload);

    NotificationService().zonedScheduleNotification(
        id: messageId,
        date: scheduleDate,
        title: message.data["title"],
        body: message.data["body"],
        payload: stringJsonPayload,
        notificationSource: message.data["topic"]);
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
    });
  }
}

Future<String> initializeApp() async {
  try {
    debugPrint("------ 1");
    await Firebase.initializeApp().timeout(const Duration(seconds: 5)).then((value) async {
      debugPrint("------ 2");
      await Globals.initGlobals();
      debugPrint("------ 3");
      registerUserIdInFirestore();
      debugPrint("------ 4");
      await NotificationService().initNotifications();
      debugPrint("------ 5");
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
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
    ]).then((value) {
      return !value.contains(false);
    });
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
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initNotifications();

  runApp(
    FutureBuilder(
      future: initializeApp().timeout(const Duration(seconds: 5)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const App();
        }
        if (snapshot.hasData && snapshot.data == "true") {
          return const App();
        } else {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/splash_image.png",
                      height: 200,
                      width: 200,
                    ),
                  ],
                );
              } else {
                return const App();
              }
            },
          );
        }
      },
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    HomeWidget.registerBackgroundCallback(backgroundCallback);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
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

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      showDialog(
          context: context,
          builder: (buildContext) => AlertDialog(
                title: Text('App started from HomeScreenWidget'),
                content: Text('Here is the URI: $uri'),
              ));
    }
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
          navigatorObservers: <NavigatorObserver>[App.observer],
          home: FutureBuilder(
            future: FirebaseDynamicLink.configureAppFromDynamicLinkV2(context)
                .timeout(const Duration(seconds: 5))
                .then((value) => const ContainerPage()),
            builder: (context, snapshot) {
              return const ContainerPage();
            },
          ),
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

class _ContainerPageState extends State<ContainerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    debugPrint('-----------Main: Initializing');
    NotificationService().requestPermissions();
    FcmHandler(context);
    _cacheUserRelatedContents();
  }

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
