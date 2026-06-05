// ignore_for_file: avoid_unnecessary_containers
import 'package:event_calendar_v2/utils/url_helper.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/common/zoomable_image_dialog.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ContentDetailPage extends StatefulWidget {
  const ContentDetailPage(
      {super.key, this.companyContentModel, this.index, this.inAppDialogSource = false, this.callback});

  final CompanyContentModel? companyContentModel;
  final int? index;
  final bool inAppDialogSource;
  final Function? callback;

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  _getFormattedDate(String dt) {
    DateTime date = DateTime.parse(dt).toLocal();
    LocalDate etDate = MonthModel.toEc(year: date.year, month: date.month, day: date.day)!;
    String formattedDate = "${MonthGlobals.etMonthsLong[etDate.month! - 1]} ${etDate.day}, ${etDate.year}";
    return formattedDate;
  }

  bool deletedContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Hero(
                transitionOnUserGestures: true,
                tag: "CONTENT_IMAGE_${widget.index}",
                child: Card(
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  child: InkWell(
                      onDoubleTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Theme.of(context).dialogBackgroundColor,
                          barrierDismissible: true,
                          builder: (_) => ZoomableImageDialog(
                            imageUrl: widget.companyContentModel!.imageUrl,
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            child: CachedNetworkImage(
                              imageUrl: widget.companyContentModel!.imageUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Theme.of(context).dialogBackgroundColor,
                                  barrierDismissible: true,
                                  builder: (_) => ZoomableImageDialog(
                                    imageUrl: widget.companyContentModel!.imageUrl,
                                  ),
                                );
                              },
                              child: Container(
                                  // color: Colors.white.withOpacity(0.3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  ),
                                  height: 25,
                                  width: 25,
                                  child: Icon(
                                    Icons.open_in_full,
                                    size: 15,
                                    color: Colors.black.withOpacity(0.5),
                                  )),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.companyContentModel!.title!, style: const TextStyle(fontSize: 30)),
                      Text(widget.companyContentModel!.companyName!,
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      Text(_getFormattedDate(widget.companyContentModel!.frD!),
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      const Divider(),
                      Text(
                        widget.companyContentModel!.body!,
                        style: const TextStyle(),
                      ),
                      const Divider(),
                      TextButton(
                          onPressed: () {
                            UrlHelper.launchURL(widget.companyContentModel!.webUrl!);
                          },
                          child: Text(AppLocalizations.of(context)!.clickHereToOpenSource,
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.blue))),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: IconButton(
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
                              '${AppLocalizations.of(context)!.areYouSureYouWantToDelete} ${widget.companyContentModel!.title}?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx, rootNavigator: true).pop(false);
                              },
                              child: const Icon(
                                Icons.undo,
                                size: 30,
                                color: Colors.blueAccent,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                String? deletedId = "";
                                setState(() {
                                  String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
                                  deletedId = widget.companyContentModel!.id;

                                  if (deletedIds != null) {
                                    deletedIds = "$deletedIds $deletedId";
                                  } else {
                                    deletedIds = "$deletedId ";
                                  }
                                  deletedContent = true;
                                  Globals.prefs!.setString(Constants.DeletedContentsId, deletedIds);
                                });
                                Navigator.of(context, rootNavigator: true).pop(true);
                                if (widget.inAppDialogSource == true) {
                                  if (widget.callback != null) widget.callback!();
                                } else {
                                  showUndoConfirmationSnackBar(ctx, deletedId);
                                }
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
                  icon: Icon(
                    Icons.delete_forever,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  )),
              trailing: IconButton(
                  onPressed: () {
                    debugPrint("------ Web url: ${widget.companyContentModel!.webUrl}");
                    if (widget.companyContentModel!.webUrl != null && widget.companyContentModel!.webUrl!.isNotEmpty) {
                      Share.share(
                          "${widget.companyContentModel!..title}\n\n${widget.companyContentModel!.body}\n\n${widget.companyContentModel!.webUrl}",
                          subject: widget.companyContentModel!.title);
                    } else {
                      Share.share(
                          "${widget.companyContentModel!.title}\n\n${widget.companyContentModel!.body}\n\n${widget.companyContentModel!.imageUrl}",
                          subject: widget.companyContentModel!.title);
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
    );
  }

  void showUndoConfirmationSnackBar(BuildContext ctx, var deletedId) {
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
            debugPrint("------ Deleted id: $deletedId");
            String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
            debugPrint("------ Deleted ids list: $deletedIds");
            String updatedIdList = deletedIds!.replaceAll(deletedId, '');
            debugPrint("------ Deleted ids after: $updatedIdList");
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
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      ),
      duration: const Duration(seconds: 10),
    ));
  }
}
