import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/events/widgets/content_detail_page.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

import 'animation/animated_logo.dart';
import 'widgets/single_month_container.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CompanyContentModel> _list = List.empty(growable: true);
  List<CompanyContentModel> filteredList = List.empty(growable: true);
  // var company = Globals.prefs.getString(Constants.CompanyPreference);
  // String? themePref = Globals.prefs!.getString(Constants.ThemePreference);
  List<String?> topics = [];

  LogoLocation? logoLocation;
  AdsScreenLocation? adsScreenLocation;

  Color? carouselBg;
  Color? contentBg;

  @override
  void initState() {
    super.initState();
    _positionAdsScreenAndLogo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAdsContentColors();
  }

  _initAdsContentColors() {
    carouselBg = Theme.of(context).dialogBackgroundColor.withOpacity(0.2);
    contentBg = Theme.of(context).dialogBackgroundColor.withOpacity(0.4);
  }

  Alignment _logoLocation() {
    switch (logoLocation) {
      case LogoLocation.topLeft:
        return Alignment.topLeft;
      case LogoLocation.topRight:
        return Alignment.topRight;
      case LogoLocation.bottomRight:
        return Alignment.bottomRight;
      case LogoLocation.bottomLeft:
        return Alignment.bottomLeft;
      default:
        return Alignment.topLeft;
    }
  }

  _positionAdsScreenAndLogo() {
    logoLocation = LogoLocation.topRight;
    adsScreenLocation = AdsScreenLocation.left;
    if (Globals.setting.expirationDate == null) {
      Globals.initCompanySettingFromLocalIfAny();
    }
    try {
      String? logoLoc = Globals.setting.logoLocation;
      String? adsScreenLoc = Globals.setting.adsScreenLocation;
      debugPrint("------ Logo Location: $logoLoc");
      debugPrint("------ Ad Screen Location $adsScreenLoc");

      if (logoLoc != null && logoLoc.isNotEmpty) {
        logoLocation = LogoLocation.values.firstWhere((e) => e.toString().split(".").last.toLowerCase() == logoLoc);
      } else {
        logoLocation = LogoLocation.topRight;
      }
      if (adsScreenLoc != null && adsScreenLoc.isNotEmpty) {
        adsScreenLocation = AdsScreenLocation.values.firstWhere((e) => e.toString().split(".").last == adsScreenLoc);
      } else {
        adsScreenLocation = AdsScreenLocation.left;
      }

      debugPrint("------ Logo Location Setting: $logoLocation");
      debugPrint("------ Ads Screen Location Setting: $adsScreenLocation");
    } catch (e) {
      logoLocation = LogoLocation.topRight;
      adsScreenLocation = AdsScreenLocation.left;

      debugPrint("------ Logo Location Default: $logoLocation");
      debugPrint("------ Ads Screen Location Default: $adsScreenLocation");
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width;
    double cardHeight = MediaQuery.of(context).size.height / 2;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Stack(
                alignment: _logoLocation(),
                children: [
                  Globals.monthImagesList[0] != null && Globals.monthImagesList[0]!.isNotEmpty
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: cardWidth,
                          height: cardHeight,
                          imageUrl: Globals.monthImagesList[MonthGlobals.etShowingMonth! - 1]!,
                          placeholder: (context, url) =>
                              ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              tileMode: TileMode.decal,
                              radius: 0.6,
                              colors: [
                                Colors.white,
                                Utility.colorConvert("#f7d031")!,
                                Utility.colorConvert("#f7d031")!,
                                Utility.colorConvert("#f7d031")!,
                                Utility.colorConvert("#f7d031")!.withOpacity(0.1),
                                Utility.colorConvert("#f7d031")!.withOpacity(0.1)
                              ],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 100, top: 100),
                                child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    curve: Curves.easeIn,
                                    duration: const Duration(seconds: 3),
                                    builder: (BuildContext context, double opacity, Widget? child) {
                                      return Opacity(
                                        opacity: opacity,
                                        child: Image.asset(
                                          "assets/images/default_image.png",
                                          fit: BoxFit.contain,
                                          width: 200,
                                          height: 200,
                                        ),
                                      );
                                    })),
                          ),
                        ),
                  const AnimateLogo(),
                  FutureBuilder(
                    future: _loadFreshContent(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasError && snapshot.hasData) {
                        return _loadFreshContentWidget(snapshot.data);
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: SingleMonthContainer(
                  monthNavigationListenerCallback: _monthNavigationListenerCallback,
                  companyChangedListenerCallback: _companyChangedListenerCallback),
            ),
          ],
        ),
      ),
    );
  }

  ///TODO: Load fresh contents on startup if connection is available and load with interval
  ///If connection is not available on start up, then call this as soon as a connection is available
  _loadFreshContent() async {
    var company = Globals.prefs!.getString(Constants.CompanyPreference);
    topics.clear();
    List<Topic> followedTopics = Topic.getUserSubscribedTopics();
    for (var element in followedTopics) {
      if (element.name!.contains("http")) {
        var data = element.name!.split("~");
        topics.add(data[0]);
      } else {
        topics.add(element.name);
      }
    }
    if (topics.isEmpty) topics.add("public");
    debugPrint("Subscriptions~~ $topics");

    if (company != null) {
      topics.add(company);
    } else {
      topics.add("default");
    }

    _list = await CompanyContentModel().getUserRelatedContents(company, topics);
    try {
      // List<CompanyContentModel> filteredList = List.empty(growable: true);
      for (var element in _list) {
        DateTime from = DateTime.parse(element.frD!);
        DateTime to = DateTime.parse(element.toD!);
        DateTime now = DateTime.now();

        debugPrint("------ Attempting Filter Title ${element.title} From - $from  To - $to");
        debugPrint("${now.compareTo(to) <= 0}");
        debugPrint("${now.compareTo(from) >= 0}");
        if (now.compareTo(from) >= 0 && now.compareTo(to) <= 0) {
          debugPrint("Filtered Element: ${element.title}");
          filteredList.add(element);
        }
      }
      var seen = <String>{};
      filteredList = filteredList.where((item) => seen.add(item.id.toString())).toList();
      return filteredList;
    } catch (e) {
      debugPrint("------ Filtering by date raised error!");
      debugPrint(e.toString());
      return _list;
    }
  }

  bool _isAdsScreenHorizontal() {
    if (adsScreenLocation == AdsScreenLocation.top || adsScreenLocation == AdsScreenLocation.bottom) {
      return true;
    } else {
      return false;
    }
  }

  _loadFreshContentWidget(dynamic list) {
    List<Container> contents = List.generate(list.length, (index) {
      debugPrint("IS ADS SCREEN HORIZONTAL~~ ${_isAdsScreenHorizontal()}");
      if (_isAdsScreenHorizontal()) {
        return _getHorizontalContentProvider(index);
      } else {
        return _getVerticalContentProvider(index);
      }
    }, growable: true);

    if (_isAdsScreenHorizontal()) {
      if (contents.isNotEmpty) {
        return _playHorizontalCarousel(contents);
      } else {
        return Container();
      }
    } else if (contents.isNotEmpty) {
      return _playVerticalCarousel(contents);
    } else {
      return Container();
    }
  }

  _getHorizontalContentProvider(index) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                    FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                    return ContentDetailPage(companyContentModel: filteredList[index], index: index);
                  },
                ));
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Hero(
                      tag: "CONTENT_IMAGE_$index",
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 100,
                        imageUrl: filteredList[index].imageUrl!,
                        placeholder: (context, url) =>
                            ConstrainedBox(constraints: const BoxConstraints(minHeight: 100), child: Container()),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                      ),
                    )),
              ),
              const VerticalDivider(
                thickness: 1,
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(filteredList[index].title!,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Flexible(child: Text(filteredList[index].body!, overflow: TextOverflow.ellipsis, maxLines: 2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _getVerticalContentProvider(index) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                filteredList[index].title ?? "",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              thickness: 1,
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: "CONTENT_IMAGE_$index",
                  child: Opacity(
                    opacity: 0.8,
                    child: CachedNetworkImage(
                      imageUrl: filteredList[index].imageUrl!,
                      placeholder: (context, url) =>
                          ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(filteredList[index].body!,
                  textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  _playHorizontalCarousel(List<Container> contents) {
    return Column(
      mainAxisAlignment:
          adsScreenLocation == AdsScreenLocation.bottom ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).dialogBackgroundColor.withOpacity(0.4),
          child: CarouselSlider(
            options: CarouselOptions(
                aspectRatio: 5.0,
                autoPlayInterval: _getAutoPlayInterval(contents),
                viewportFraction: 1,
                autoPlay: contents.length > 1 ? true : false,
                scrollDirection: Globals.setting.verticalAxisAdsAnimation! ? Axis.vertical : Axis.horizontal,
                enlargeCenterPage: true,
                reverse: Globals.setting.reverseAdsAnimation!),
            items: contents.map((content) {
              return content;
            }).toList(),
          ),
        ),
      ],
    );
  }

  Duration _getAutoPlayInterval(List<Container> contents) {
    int items = contents.length;
    if (items < 5) {
      return const Duration(seconds: 5);
    } else {
      return const Duration(seconds: 3);
    }
  }

  _playVerticalCarousel(List<Container> contents) {
    int contentLength = contents.length;
    if (contentLength == 0) return Container();
    return Row(
      mainAxisAlignment: adsScreenLocation == AdsScreenLocation.right ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).dialogBackgroundColor.withOpacity(0.2),
          width: MediaQuery.of(context).size.width / 2.5,
          height: MediaQuery.of(context).size.height,
          child: CarouselSlider.builder(
            options: CarouselOptions(
                aspectRatio: 1.0,
                viewportFraction: 1,
                enableInfiniteScroll: true,
                enlargeCenterPage: true,
                scrollDirection: Globals.setting.verticalAxisAdsAnimation! ? Axis.vertical : Axis.horizontal,
                autoPlayInterval: _getAutoPlayInterval(contents),
                autoPlay: contents.length > 2 ? true : false,
                reverse: Globals.setting.reverseAdsAnimation!),
            itemCount: (contents.length / 2).round(),
            itemBuilder: (context, index, realIdx) {
              int first = index * 2;
              int second = first + 1;
              if (second >= contents.length) {
                second = 0;
              }
              List<int> columnLength = contentLength > 1 ? [first, second] : [first];
              return Column(
                children: columnLength.map((idx) {
                  return Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                                  FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                                  return ContentDetailPage(companyContentModel: filteredList[idx], index: idx);
                                },
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: contents[idx],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  _monthNavigationListenerCallback() {
    setState(() {});
  }

  _companyChangedListenerCallback() {
    setState(() {
      _positionAdsScreenAndLogo();
      _logoLocation();
    });
  }
}
