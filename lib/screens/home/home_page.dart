import 'dart:ui';
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
  List<String?> topics = [];

  LogoLocation? logoLocation;
  AdsScreenLocation? adsScreenLocation;

  Color? carouselBg;
  Color? contentBg;

  bool _isAdsExpanded = false;
  late Future<List<CompanyContentModel>> _loadFreshContentFuture;

  @override
  void initState() {
    super.initState();
    _positionAdsScreenAndLogo();
    _loadFreshContentFuture = _loadFreshContent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAdsContentColors();
  }

  _initAdsContentColors() {
    carouselBg = Theme.of(context).dialogBackgroundColor.withValues(alpha: 0.2);
    contentBg = Theme.of(context).dialogBackgroundColor.withValues(alpha: 0.4);
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
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Stack(
                    alignment: _logoLocation(),
                    children: [
                      Globals.monthImagesList[0] != null &&
                              Globals.monthImagesList[0]!.isNotEmpty &&
                              MonthGlobals.etShowingMonth != null
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: cardWidth,
                              height: cardHeight,
                              imageUrl: Globals.monthImagesList[MonthGlobals.etShowingMonth! - 1] ?? '',
                              placeholder: (context, url) =>
                                  ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            )
                          : Container(
                              width: cardWidth,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context).primaryColor.withValues(alpha: 0.25),
                                    Theme.of(context).scaffoldBackgroundColor,
                                  ],
                                ),
                              ),
                            ),
                      const AnimateLogo(),
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
            FutureBuilder<List<CompanyContentModel>>(
              future: _loadFreshContentFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildCollapsibleAdsPanel(snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<CompanyContentModel>> _loadFreshContent() async {
    var company = Globals.prefs!.getString(Constants.CompanyPreference);
    List<String?> localTopics = [];
    List<Topic> followedTopics = Topic.getUserSubscribedTopics();
    for (var element in followedTopics) {
      if (element.name != null) {
        if (element.name!.contains("http")) {
          var data = element.name!.split("~");
          localTopics.add(data[0]);
        } else {
          localTopics.add(element.name);
        }
      }
    }
    if (localTopics.isEmpty) localTopics.add("public");
    debugPrint("Subscriptions~~ $localTopics");

    if (company != null) {
      localTopics.add(company);
    } else {
      localTopics.add("default");
    }

    _list = await CompanyContentModel().getUserRelatedContents(company, localTopics);
    List<CompanyContentModel> localFilteredList = [];
    try {
      for (var element in _list) {
        if (element.frD == null || element.toD == null) {
          continue;
        }
        DateTime? from = DateTime.tryParse(element.frD!);
        DateTime? to = DateTime.tryParse(element.toD!);
        if (from == null || to == null) continue;
        DateTime now = DateTime.now();

        debugPrint("------ Attempting Filter Title ${element.title} From - $from  To - $to");
        if (now.compareTo(from) >= 0 && now.compareTo(to) <= 0) {
          debugPrint("Filtered Element: ${element.title}");
          localFilteredList.add(element);
        }
      }
      var seen = <String>{};
      localFilteredList = localFilteredList.where((item) => item.id != null && seen.add(item.id.toString())).toList();

      if (mounted) {
        setState(() {
          topics = localTopics;
          filteredList = localFilteredList;
        });
      } else {
        topics = localTopics;
        filteredList = localFilteredList;
      }
      return localFilteredList;
    } catch (e) {
      debugPrint("------ Filtering by date raised error!");
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          topics = localTopics;
          filteredList = _list;
        });
      } else {
        topics = localTopics;
        filteredList = _list;
      }
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

  Widget _buildCollapsibleAdsPanel(List<CompanyContentModel> ads) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double panelWidth = (screenWidth * 0.65).clamp(220.0, 260.0);
    const double tabWidth = 52.0;
    const double panelHeight = 220.0;
    const double tabHeight = 44.0;

    final isHorizontal = _isAdsScreenHorizontal();

    double? left, right, top, bottom, width, height;

    if (adsScreenLocation == AdsScreenLocation.left) {
      left = _isAdsExpanded ? 0 : -panelWidth;
      top = 0;
      bottom = 0;
      width = panelWidth + tabWidth;
    } else if (adsScreenLocation == AdsScreenLocation.right) {
      right = _isAdsExpanded ? 0 : -panelWidth;
      top = 0;
      bottom = 0;
      width = panelWidth + tabWidth;
    } else if (adsScreenLocation == AdsScreenLocation.top) {
      top = _isAdsExpanded ? 0 : -panelHeight;
      left = 0;
      right = 0;
      height = panelHeight + tabHeight;
    } else {
      bottom = _isAdsExpanded ? 0 : -panelHeight;
      left = 0;
      right = 0;
      height = panelHeight + tabHeight;
    }

    return Stack(
      children: [
        if (_isAdsExpanded)
          GestureDetector(
            onTap: () => setState(() => _isAdsExpanded = false),
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          left: left,
          right: right,
          top: top,
          bottom: bottom,
          width: width,
          height: height,
          child: _buildPanelAndTabContent(
            ads: ads,
            isHorizontal: isHorizontal,
            panelWidth: panelWidth,
            tabWidth: tabWidth,
            panelHeight: panelHeight,
            tabHeight: tabHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildPanelAndTabContent({
    required List<CompanyContentModel> ads,
    required bool isHorizontal,
    required double panelWidth,
    required double tabWidth,
    required double panelHeight,
    required double tabHeight,
  }) {
    if (adsScreenLocation == AdsScreenLocation.left) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: _buildPanel(ads),
          ),
          SizedBox(
            width: tabWidth,
            child: _buildTab(ads.length),
          ),
        ],
      );
    } else if (adsScreenLocation == AdsScreenLocation.right) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: tabWidth,
            child: _buildTab(ads.length),
          ),
          SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: _buildPanel(ads),
          ),
        ],
      );
    } else if (adsScreenLocation == AdsScreenLocation.top) {
      final bool isMenuLeft = Globals.setting.leftMenu ?? true;
      final horizontalAlignment = isMenuLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start;
      return Column(
        crossAxisAlignment: horizontalAlignment,
        children: [
          SizedBox(
            height: panelHeight,
            width: double.infinity,
            child: _buildPanel(ads),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isMenuLeft ? 0 : 20.0,
              right: isMenuLeft ? 20.0 : 0,
            ),
            child: SizedBox(
              height: tabHeight,
              child: _buildTab(ads.length),
            ),
          ),
        ],
      );
    } else {
      final bool isMenuLeft = Globals.setting.leftMenu ?? true;
      final horizontalAlignment = isMenuLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start;
      return Column(
        crossAxisAlignment: horizontalAlignment,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMenuLeft ? 0 : 20.0,
              right: isMenuLeft ? 20.0 : 0,
            ),
            child: SizedBox(
              height: tabHeight,
              child: _buildTab(ads.length),
            ),
          ),
          SizedBox(
            height: panelHeight,
            width: double.infinity,
            child: _buildPanel(ads),
          ),
        ],
      );
    }
  }

  Widget _buildTab(int adsCount) {
    final borderRadius = _getTabBorderRadius();
    final bool isMenuLeft = Globals.setting.leftMenu ?? true;
    final alignment = _isAdsScreenHorizontal()
        ? (isMenuLeft ? Alignment.centerRight : Alignment.centerLeft)
        : Alignment.center;

    return GestureDetector(
      onTap: () => setState(() => _isAdsExpanded = !_isAdsExpanded),
      child: Align(
        alignment: alignment,
        child: Container(
          width: _isAdsScreenHorizontal() ? 80.0 : 44.0,
          height: _isAdsScreenHorizontal() ? 32.0 : 60.0,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.85),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                _isAdsExpanded ? Icons.close : Icons.campaign_rounded,
                color: Colors.white,
                size: 20.0,
              ),
              if (!_isAdsExpanded && adsCount > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: _buildNotificationBadge(adsCount),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _getTabBorderRadius() {
    switch (adsScreenLocation) {
      case AdsScreenLocation.left:
        return const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
      case AdsScreenLocation.right:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        );
      case AdsScreenLocation.top:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
      case AdsScreenLocation.bottom:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        );
      default:
        return BorderRadius.circular(12);
    }
  }

  Widget _buildNotificationBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPanel(List<CompanyContentModel> ads) {
    final borderRadius = _getPanelBorderRadius();
    final isHorizontal = _isAdsScreenHorizontal();

    List<Container> contents = List.generate(ads.length, (index) {
      if (isHorizontal) {
        return _getHorizontalContentProvider(index);
      } else {
        return _getVerticalContentProvider(index);
      }
    }, growable: true);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
            borderRadius: borderRadius,
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (adsScreenLocation == AdsScreenLocation.left && details.primaryDelta! < -10) {
                setState(() => _isAdsExpanded = false);
              } else if (adsScreenLocation == AdsScreenLocation.right && details.primaryDelta! > 10) {
                setState(() => _isAdsExpanded = false);
              }
            },
            onVerticalDragUpdate: (details) {
              if (adsScreenLocation == AdsScreenLocation.top && details.primaryDelta! < -10) {
                setState(() => _isAdsExpanded = false);
              } else if (adsScreenLocation == AdsScreenLocation.bottom && details.primaryDelta! > 10) {
                setState(() => _isAdsExpanded = false);
              }
            },
            child: SafeArea(
              top: false,
              bottom: false,
              left: adsScreenLocation == AdsScreenLocation.left,
              right: adsScreenLocation == AdsScreenLocation.right,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Center(
                      child: Text(
                        "Featured",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  Expanded(
                    child: contents.isEmpty
                        ? const SizedBox.shrink()
                        : (isHorizontal
                            ? _playHorizontalCarousel(contents)
                            : _playVerticalCarousel(contents)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _getPanelBorderRadius() {
    switch (adsScreenLocation) {
      case AdsScreenLocation.left:
        return const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      case AdsScreenLocation.right:
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      case AdsScreenLocation.top:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      case AdsScreenLocation.bottom:
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        );
      default:
        return BorderRadius.circular(20);
    }
  }

  _getHorizontalContentProvider(index) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
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
                flex: 2,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Hero(
                      tag: "CONTENT_IMAGE_$index",
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: double.infinity,
                        imageUrl: filteredList[index].imageUrl ?? '',
                        placeholder: (context, url) => Container(color: Colors.grey.withValues(alpha: 0.2)),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.campaign_rounded, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    )),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 0.5,
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(filteredList[index].title ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: Text(
                          filteredList[index].body ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(11)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: "CONTENT_IMAGE_$index",
              child: Opacity(
                opacity: 0.95,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: filteredList[index].imageUrl ?? "",
                  placeholder: (context, url) => Container(
                    color: Colors.grey.withValues(alpha: 0.2),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(Icons.campaign_rounded, size: 48, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black.withValues(alpha: 0.65),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filteredList[index].title ?? "",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          filteredList[index].body ?? "",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _playHorizontalCarousel(List<Container> contents) {
    return CarouselSlider(
      options: CarouselOptions(
          aspectRatio: 2.8,
          autoPlayInterval: _getAutoPlayInterval(contents),
          viewportFraction: 1.0,
          autoPlay: contents.length > 1 ? true : false,
          scrollDirection: Globals.setting.verticalAxisAdsAnimation! ? Axis.vertical : Axis.horizontal,
          enlargeCenterPage: false,
          reverse: Globals.setting.reverseAdsAnimation!),
      items: contents.map((content) {
        return content;
      }).toList(),
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
    if (contentLength == 0) return const SizedBox.shrink();
    return CarouselSlider.builder(
      options: CarouselOptions(
          aspectRatio: 0.6,
          viewportFraction: 1.0,
          enableInfiniteScroll: contents.length > 2,
          enlargeCenterPage: false,
          scrollDirection: Globals.setting.verticalAxisAdsAnimation! ? Axis.vertical : Axis.horizontal,
          autoPlayInterval: _getAutoPlayInterval(contents),
          autoPlay: contents.length > 2 ? true : false,
          reverse: Globals.setting.reverseAdsAnimation!),
      itemCount: (contents.length / 2).round(),
      itemBuilder: (context, index, realIdx) {
        int first = index * 2;
        int second = first + 1;
        bool showSecond = second < contents.length;
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                            FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                            return ContentDetailPage(companyContentModel: filteredList[first], index: first);
                          },
                        ));
                  },
                  child: contents[first],
                ),
              ),
            ),
            Expanded(
              child: showSecond
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                                  FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                                  return ContentDetailPage(companyContentModel: filteredList[second], index: second);
                                },
                              ));
                        },
                        child: contents[second],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  _monthNavigationListenerCallback() {
    setState(() {});
  }

  _companyChangedListenerCallback() {
    setState(() {
      _positionAdsScreenAndLogo();
      _logoLocation();
      _loadFreshContentFuture = _loadFreshContent();
    });
  }
}
