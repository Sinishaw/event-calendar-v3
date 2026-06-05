import 'package:event_calendar_v2/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CopyRightMenuItem extends StatelessWidget {
  const CopyRightMenuItem({super.key, required this.text, this.iconsColor});
  final String text;
  final Color? iconsColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.share),
                color: iconsColor,
                onPressed: () {
                  Share.share(
                      '13 Months of Ethiopian Calendar https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar&hl=en&gl=US&showAllReviews=true');
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star_rate,
                  color: iconsColor,
                ),
                onPressed: () async {
                  try {
                    UrlHelper.launchURL("market://details?id=com.elexicon.ethiopiancalendar");
                  } on PlatformException {
                    UrlHelper.launchURL("https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar");
                  } finally {
                    UrlHelper.launchURL("https://play.google.com/store/apps/details?id=com.elexicon.ethiopiancalendar");
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
