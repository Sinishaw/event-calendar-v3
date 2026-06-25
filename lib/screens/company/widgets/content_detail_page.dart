import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/common/zoomable_image_dialog.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ContentDetailPage extends StatefulWidget {
  const ContentDetailPage({
    super.key,
    this.companyContentModel,
    this.index,
    required this.inAppDialogSource,
    this.callback,
  });
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

  void _confirmDeleteDialog(BuildContext context) {
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
                      '${AppLocalizations.of(context)!.areYouSureYouWantToDelete} "${widget.companyContentModel!.title}"?',
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
                        // Cancel
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(ctx, rootNavigator: true).pop(false);
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
                              String? deletedId = widget.companyContentModel!.id;
                              setState(() {
                                String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
                                if (deletedIds != null) {
                                  deletedIds = "$deletedIds $deletedId";
                                } else {
                                  deletedIds = "$deletedId ";
                                }
                                deletedContent = true;
                                Globals.prefs!.setString(Constants.DeletedContentsId, deletedIds);
                              });
                              
                              Navigator.of(ctx, rootNavigator: true).pop(true); // Pop dialog
                              Navigator.of(context).pop(true); // Pop details page
                              
                              if (widget.inAppDialogSource == true) {
                                if (widget.callback != null) widget.callback!();
                              } else {
                                // Show snackbar on parent context
                                showUndoConfirmationSnackBar(context, deletedId!);
                              }
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
    final primaryColor = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    final content = widget.companyContentModel!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Parallax Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurface, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onDoubleTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => ZoomableImageDialog(
                      imageUrl: content.imageUrl,
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: content.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: primaryColor.withValues(alpha: 0.05),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: primaryColor.withValues(alpha: 0.05),
                        child: Icon(Icons.broken_image_rounded, color: primaryColor.withValues(alpha: 0.4), size: 48),
                      ),
                    ),
                    // Shadow overlay for bottom contrast
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black38,
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                    // Expand/Zoom icon
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => ZoomableImageDialog(
                              imageUrl: content.imageUrl,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content.title!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata section
                  Row(
                    children: [
                      Icon(Icons.business_rounded, size: 14, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        content.companyName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_rounded, size: 12, color: onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 6),
                      Text(
                        _getFormattedDate(content.frD!),
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Premium custom Divider
                  Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.4),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Article body text
                  Text(
                    content.body!,
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurface.withValues(alpha: 0.8),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Source Link Section
                  if (content.webUrl != null && content.webUrl!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: () => UrlHelper.launchURL(content.webUrl!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.launch_rounded, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.clickHereToOpenSource,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Fixed bottom actions bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Delete action
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDeleteDialog(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                label: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Share action
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint("Web url: ${content.webUrl}");
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
                },
                icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                label: const Text(
                  "Share",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
