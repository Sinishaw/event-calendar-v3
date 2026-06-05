import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static bool isLinkAvailable(String? url) {
    if (url != null && url.isNotEmpty) return true;
    return false;
  }

  static void launchURL(String url) async =>
      await canLaunchUrl(Uri.parse(url)) ? await launchInBrowser(Uri.parse(url)) : throw 'Could not launch $url';

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static void composeMail({String? scheme, String? path, String? subject}) {
    final Uri emailLaunchUri = Uri(
      scheme: scheme ?? "",
      path: path ?? "",
      query: encodeQueryParameters(<String, String>{
        'subject': subject ?? "",
      }),
    );
    launchUrl(emailLaunchUri);
  }

  /// Encode [params] so it produces a correct query string.
  /// Workaround for: https://github.com/dart-lang/sdk/issues/43838
  // #docregion encode-query-parameters
  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
