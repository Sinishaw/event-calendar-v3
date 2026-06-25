import 'package:event_calendar_v2/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CopyRightMenuItem extends StatelessWidget {
  const CopyRightMenuItem({super.key, required this.text, this.iconsColor});
  final String text;
  final Color? iconsColor;
  @override
  Widget build(BuildContext context) {
    Color? colorToUse = iconsColor ?? Theme.of(context).primaryColor;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w300, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: colorToUse,
                onPressed: () {
                  final RenderBox? box = context.findRenderObject() as RenderBox?;
                  Share.share(
                    '13 Months of Ethiopian Calendar https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar&hl=en&gl=US&showAllReviews=true',
                    sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star_rate,
                  color: colorToUse,
                  size: 20,
                ),
                onPressed: () async {
                  final bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
                  if (isIos) {
                    try {
                      UrlHelper.launchURL("itms-apps://itunes.apple.com/app/com.elexicon.ethiopiancalendar");
                    } catch (_) {
                      UrlHelper.launchURL("https://apps.apple.com/app/com.elexicon.ethiopiancalendar");
                    }
                  } else {
                    try {
                      UrlHelper.launchURL("market://details?id=com.elexicon.ethiopiancalendar");
                    } catch (_) {
                      UrlHelper.launchURL("https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

}
