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
  int selectedIndex = -1;
  bool _shouldForceRefresh = false;

  Future<List<CompanyContentModel>> _getContents() async {
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
    _listContent = await CompanyContentModel().getUserRelatedContents(
      company,
      topics,
      forceRefresh: _shouldForceRefresh,
    );
    _shouldForceRefresh = false;
    return _listContent;
  }

  detailChangeCallback() {
    setState(() {});
  }

  Widget _getListWidget(List<CompanyContentModel> list) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;
    final cardBg = theme.cardColor;

    return list.isNotEmpty
        ? ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemBuilder: (context, index) {
              final content = list[index];
              final isSelectedForDelete = selectedIndex == index;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(isDark ? 0.35 : 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            FirebaseLogger.logGlobalScreenView(LogScreen.CompanyContentDetail.index);
                            FirebaseLogger.logCompanyScreenView(LogScreen.CompanyContentDetail.index);
                            return ContentDetailPage(
                              companyContentModel: content,
                              index: index,
                              inAppDialogSource: true,
                              callback: detailChangeCallback,
                            );
                          },
                        ),
                      );
                    },
                    onLongPress: () {
                      setState(() {
                        selectedIndex = isSelectedForDelete ? -1 : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Logo + Title & Subtitle + Deletion control)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Company Logo
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: CachedNetworkImage(
                                    imageUrl: content.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.business_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title & Company Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content.title!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      content.companyName!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Delete/Select Actions
                              if (isSelectedForDelete)
                                IconButton(
                                  onPressed: () => _confirmDeleteDialog(context, content, index),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Main Image (Banner)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Hero(
                              tag: "CONTENT_IMAGE_$index",
                              child: CachedNetworkImage(
                                imageUrl: content.imageUrl!,
                                placeholder: (context, url) => ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 200),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: primaryColor.withValues(alpha: 0.05),
                                  child: Icon(Icons.broken_image_rounded, color: primaryColor.withValues(alpha: 0.4), size: 40),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Body text preview
                          Text(
                            content.body!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Footer (Date + Share)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${Utility.getFormattedEtDate(content.frD)}",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  debugPrint("Sharing Content: ${content.title}");
                                  final RenderBox? box = context.findRenderObject() as RenderBox?;
                                  final sharePositionOrigin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
                                  if (content.webUrl != null && content.webUrl!.isNotEmpty) {
                                    Share.share(
                                      "${content.title}\n\n${content.body}\n\n${content.webUrl}",
                                      subject: content.title,
                                      sharePositionOrigin: sharePositionOrigin,
                                    );
                                  } else {
                                    Share.share(
                                      "${content.title}\n\n${content.body}\n\n${content.imageUrl}",
                                      subject: content.title,
                                      sharePositionOrigin: sharePositionOrigin,
                                    );
                                  }
                                  Globals.prefs!.remove(Constants.DeletedContentsId);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.share_rounded,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Share",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 48,
                  color: primaryColor.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.noDocumentIsFound,
                  style: TextStyle(
                    fontSize: 14,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          );
  }

  void _confirmDeleteDialog(BuildContext context, CompanyContentModel content, int index) {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext ctx) {
        final theme = Theme.of(context);
        final primary = theme.primaryColor;
        final isDark = theme.brightness == Brightness.dark;
        final onSurface = theme.colorScheme.onSurface;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.18),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.redAccent.withValues(alpha: isDark ? 0.45 : 0.15),
                          Colors.redAccent.withValues(alpha: isDark ? 0.20 : 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.confirmDeletion,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Accent Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withValues(alpha: 0.5),
                          Colors.redAccent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  // Content Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Text(
                      '${AppLocalizations.of(context)!.areYouSureYouWantToDelete} "${content.title}"?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurface.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ),
                  ),
                  // Action buttons
                  Container(
                    height: 1,
                    color: onSurface.withValues(alpha: 0.08),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Cancel (Undo)
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(ctx, rootNavigator: true).pop(false);
                              setState(() {
                                selectedIndex = -1;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: onSurface.withValues(alpha: 0.08),
                        ),
                        // Confirm Delete
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
                                String deletedId = content.id!;
                                if (deletedIds != null) {
                                  deletedIds = "$deletedIds $deletedId";
                                } else {
                                  deletedIds = "$deletedId ";
                                }
                                Globals.prefs!.setString(Constants.DeletedContentsId, deletedIds);
                                selectedIndex = -1;
                              });
                              showUndoConfirmationSnackBar(context, content.id!);
                              Navigator.of(ctx, rootNavigator: true).pop(true);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  void showUndoConfirmationSnackBar(BuildContext context, String deletedId) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.dialogBackgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        elevation: 8,
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Article deleted",
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                debugPrint("Deleted id: $deletedId");
                String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
                if (deletedIds != null) {
                  String updatedIdList = deletedIds.replaceAll(deletedId, '').trim();
                  Globals.prefs!.setString(Constants.DeletedContentsId, updatedIdList);
                }
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() {});
              },
              icon: Icon(Icons.undo_rounded, size: 16, color: primary),
              label: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isPopable = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? AppLocalizations.of(context)!.companyChannel),
        centerTitle: true,
        leading: isPopable
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _shouldForceRefresh = true;
          await _getContents();
          setState(() {});
        },
        color: primary,
        child: FutureBuilder(
          future: _getContents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: primary,
                  strokeWidth: 3,
                ),
              );
            }
            if (snapshot.hasData) {
              return _getListWidget(snapshot.data as List<CompanyContentModel>);
            }
            return Center(
              child: Text(
                "Loading...",
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
