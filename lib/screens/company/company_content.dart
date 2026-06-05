import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/firebase_logger.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/company/widgets/content_detail_page.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CompanyContentPage extends StatefulWidget {
  static const String routeName = '/company_contents';

  const CompanyContentPage({super.key, this.title});
  final String? title;

  @override
  State<CompanyContentPage> createState() => _CompanyContentPageState();
}

class _CompanyContentPageState extends State<CompanyContentPage> {
  List<CompanyContentModel> _listContent = List.empty(growable: true);
  List<String?> topics = [];

  _getContents() async {
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
    debugPrint("Subscriptions~~ $topics");

    if (company != null) {
      topics.add(company);
    } else {
      topics.add(Constants.DefaultCompany);
    }
    _listContent = await CompanyContentModel().getUserRelatedContents(company, topics);
    return _listContent;
  }

  int selectedIndex = -1;

  detailChangeCallback() {
    setState(() {});
  }

  Widget _getListWidget(var _list) {
    String deletedId = "";
    return _list.length > 0
        ? ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return InkWell(
                onLongPress: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 20, left: 5, right: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) {
                              FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                              FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                              return ContentDetailPage(
                                companyContentModel: _list[index],
                                index: index,
                                inAppDialogSource: true,
                                callback: detailChangeCallback,
                              );
                            },
                          ));
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
                                    placeholder: (context, url) => ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 200), child: Container()),
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
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext ctx) {
                                      return AlertDialog(
                                        title: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Center(child: Text(AppLocalizations.of(context)!.confirmDeletion)),
                                          ],
                                        ),
                                        content: Text(
                                            '${AppLocalizations.of(context)!.areYouSureYouWantToDelete} ${_list[index].title}?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx, rootNavigator: true).pop(false);
                                              setState(() {
                                                selectedIndex = -1;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.undo,
                                              size: 30,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                String? deletedIds =
                                                    Globals.prefs!.getString(Constants.DeletedContentsId);
                                                deletedId = _list[index].id!;

                                                if (deletedIds != null) {
                                                  deletedIds = "$deletedIds $deletedId";
                                                } else {
                                                  deletedIds = "$deletedId ";
                                                }
                                                Globals.prefs!.setString(Constants.DeletedContentsId, deletedIds);
                                                selectedIndex = -1;
                                              });
                                              showUndoConfirmationSnackBar(ctx, deletedId);
                                              Navigator.of(ctx, rootNavigator: true).pop(true);
                                            },
                                            child: const Icon(
                                              Icons.delete_forever,
                                              size: 30,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: selectedIndex == index
                                    ? const Icon(
                                        Icons.delete_forever,
                                        size: 40,
                                      )
                                    : Container(),
                              )
                            ],
                          ),
                          const Divider(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Hero(
                              tag: "CONTENT_IMAGE_$index",
                              child: CachedNetworkImage(
                                imageUrl: _list[index].imageUrl!,
                                placeholder: (context, url) => ConstrainedBox(
                                    constraints: const BoxConstraints(minHeight: 200),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                                  "${Utility.getFormattedEtDate(_list[index].frD)}",
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: IconButton(
                                      onPressed: () {
                                        debugPrint("Web url: ${_list[index].webUrl}");
                                        if (_list[index].webUrl != null && _list[index].webUrl!.isNotEmpty) {
                                          Share.share(
                                              "${_list[index].title}\n\n${_list[index].body}\n\n${_list[index].webUrl}",
                                              subject: _list[index].title);
                                        } else {
                                          Share.share(
                                              "${_list[index].title}\n\n${_list[index].body}\n\n${_list[index].imageUrl}",
                                              subject: _list[index].title);
                                          debugPrint("No web url is available to share.");
                                        }
                                        Globals.prefs!.remove(Constants.DeletedContentsId);
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
                ),
              );
            },
          )
        : Center(
            child: InkWell(
                onLongPress: () {
                  setState(() {
                    Globals.prefs!.remove(Constants.DeletedContentsId);
                  });
                },
                child: Text(AppLocalizations.of(context)!.noDocumentIsFound!)),
          );
  }

  void showUndoConfirmationSnackBar(BuildContext ctx, String deletedId) {
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      content: ListTile(
        title: const Text("Undo Deletion"),
        leading: IconButton(
          icon: Icon(
            Icons.undo,
            color: tc,
          ),
          onPressed: () {
            debugPrint("Deleted id: $deletedId");
            String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
            debugPrint("Deleted ids list: $deletedIds");
            String updatedIdList = deletedIds!.replaceAll(deletedId, '');
            debugPrint("Deleted ids after: $updatedIdList");
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            setState(() {
              Globals.prefs!.setString(Constants.DeletedContentsId, updatedIdList.trim());
            });
          },
        ),
        trailing: IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: tc,
            ),
            onPressed: () => ScaffoldMessenger.of(this.context).hideCurrentSnackBar()),
      ),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var company = Globals.prefs!.getString(Constants.CompanyPreference);
    company ??= Constants.DefaultCompany;
    return Scaffold(
      body: FutureBuilder(
        future: _getContents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getListWidget(snapshot.data);
          }
          return const Center(child: Text("Loading..."));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
