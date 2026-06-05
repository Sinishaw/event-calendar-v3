import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'content_detail_page.dart';

class NationalDayArticlePage extends StatefulWidget {
  const NationalDayArticlePage({super.key, this.nationalDayRef, this.holidayName});
  final String? nationalDayRef;
  final String? holidayName;

  @override
  State<NationalDayArticlePage> createState() => _NationalDayArticlePageState();
}

class _NationalDayArticlePageState extends State<NationalDayArticlePage> {
  List<CompanyContentModel> _list = List.empty(growable: true);
  var company = Globals.prefs!.getString(Constants.CompanyPreference);

  // var subscriptions = Globals.prefs.getString(Constants.TopicsUserSubscribedLocal);

  final List<String?> _company = [];
  final List<String?> _nationalDay = [];

  _getContents() async {
    _company.clear();
    if (company != null) {
      _company.add(company);
    } else {
      _company.add("default");
    }

    _nationalDay.clear();
    _nationalDay.add(widget.nationalDayRef);
    _list = await CompanyContentModel().getCompanyNationalDaysArticle(_company[0], _nationalDay[0]);
    return _list;
  }

  _getContentsWidget(dynamic _list) {
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 20, left: 5, right: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    FirebaseLogger.logGlobalScreenView(LogScreen.NationalDayArticleDetail.index);
                    FirebaseLogger.logCompanyScreenView(LogScreen.NationalDayArticleDetail.index);
                    return ContentDetailPage(companyContentModel: _list[index], index: index);
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: _list[index].logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_list[index].title!, style: const TextStyle(fontSize: 25)),
                              Text(_list[index].companyName!),
                            ],
                          ),
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
                    ],
                  ),
                  const Divider(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Hero(
                      tag: "CONTENT_IMAGE_$index",
                      child: CachedNetworkImage(
                        imageUrl: _list[index].imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 200),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            )),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                    child: Text(_list[index].body!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${Utility.getFormattedEtDate(_list[index].frD.toString())}",
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: IconButton(
                              onPressed: () {
                                debugPrint("------ Web url: ${_list[index].webUrl}");
                                if (_list[index].webUrl != null && _list[index].webUrl!.isNotEmpty) {
                                  Share.share("${_list[index].title}\n\n${_list[index].body}\n\n${_list[index].webUrl}",
                                      subject: _list[index].title);
                                } else {
                                  Share.share(
                                      "${_list[index].title}\n\n${_list[index].body}\n\n${_list[index].imageUrl}",
                                      subject: _list[index].title);
                                  debugPrint("------ No web url is available to share.");
                                }
                              },
                              icon: Icon(
                                Icons.share,
                                color: Theme.of(context).primaryColor,
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Column _noContentIsFoundText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.noDocumentIsFound),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.holidayName!),
      ),
      body: company != null
          ? FutureBuilder(
              future: _getContents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  if (_list.isEmpty) return Center(child: _noContentIsFoundText());
                  return _getContentsWidget(snapshot.data);
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
                  return Center(child: _noContentIsFoundText());
                } else {
                  return const Center(
                    child: Text("Something went wrong, Please try again later"),
                  );
                }
              },
            )
          : Center(
              child: _noContentIsFoundText(),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
