import 'package:event_calendar_v2/screens/company/widgets/company_picker_dialog.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatefulWidget {
  static const String routeName = '/about';
  const AboutPage({super.key, this.title});
  final String? title;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    Color stripe = Theme.of(context).primaryColor.withOpacity(0.05);
    TextStyle ts = const TextStyle(fontWeight: FontWeight.w200, fontSize: 22);

    TextStyle smallStyle = const TextStyle(fontWeight: FontWeight.w200, fontSize: 16, fontStyle: FontStyle.italic);

    double height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: [
            Text(AppLocalizations.of(context)!.serviceProvider),
            Text(AppLocalizations.of(context)!.developer)
          ]),
          title: Center(child: Text(AppLocalizations.of(context)!.aboutApp)),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: TabBarView(
            children: [
              Globals.setting.profile != null
                  ? ListView(
                      children: [
                        UrlHelper.isLinkAvailable(Globals.setting.profile!.iUrl)
                            ? ConstrainedBox(
                                constraints: BoxConstraints(minHeight: height / 5, maxHeight: height / 4),
                                child: Globals.setting.profile != null && Globals.setting.profile!.iUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: Globals.setting.profile!.iUrl!,
                                        placeholder: (context, url) => ConstrainedBox(
                                          constraints: const BoxConstraints(minHeight: 200),
                                          child: Container(),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                      )
                                    : Container(),
                              )
                            : const Center(child: Text("No image available.")),
                        const Divider(),
                        Container(
                            color: stripe,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 100),
                                    child: CachedNetworkImage(
                                      imageUrl: Globals.setting.logo!,
                                      fit: BoxFit.scaleDown,
                                      placeholder: (context, url) => ConstrainedBox(
                                          constraints: const BoxConstraints(minHeight: 200), child: Container()),
                                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("This app is deliver to you by:-"),
                                      Text(
                                        "(${Globals.setting.companyName})",
                                        style: ts,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                        const Divider(),
                        Container(
                          height: 50,
                          color: stripe,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "",
                                ),
                              ),
                              const VerticalDivider(),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  child: SingleChildScrollView(
                                    child: Text("${Globals.setting.profile!.description}"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Container(
                          height: 50,
                          color: stripe,
                          child: GestureDetector(
                              onTap: () {
                                UrlHelper.makePhoneCall("${Globals.setting.profile!.phone}");
                              },
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.phoneFlip),
                                  ),
                                  const VerticalDivider(),
                                  Text(
                                    "${Globals.setting.profile!.phone}",
                                    style: smallStyle,
                                  )
                                ],
                              )),
                        ),
                        const Divider(),
                        Container(
                          height: 50,
                          color: stripe,
                          child: GestureDetector(
                              onTap: () {
                                UrlHelper.launchURL(Globals.setting.profile!.website!);
                              },
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.globe),
                                  ),
                                  const VerticalDivider(),
                                  Text(
                                    "${Globals.setting.profile!.website}",
                                    style: smallStyle,
                                  )
                                ],
                              )),
                        ),
                        const Divider(),
                        Container(
                          height: 50,
                          color: stripe,
                          child: GestureDetector(
                              onTap: () {
                                UrlHelper.launchURL("mailto:${Globals.setting.profile!.email}");
                              },
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.envelope),
                                  ),
                                  const VerticalDivider(),
                                  Text(
                                    "${Globals.setting.profile!.email}",
                                    style: smallStyle,
                                  )
                                ],
                              )),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.facebook),
                              onPressed: UrlHelper.isLinkAvailable(Globals.setting.profile!.facebook)
                                  ? () {
                                      UrlHelper.launchURL(Globals.setting.profile!.facebook!);
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.twitter),
                              onPressed: UrlHelper.isLinkAvailable(Globals.setting.profile!.twitter)
                                  ? () {
                                      UrlHelper.launchURL(Globals.setting.profile!.twitter!);
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram),
                              onPressed: UrlHelper.isLinkAvailable(Globals.setting.profile!.instagram)
                                  ? () {
                                      UrlHelper.launchURL(Globals.setting.profile!.instagram!);
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.youtube),
                              onPressed: UrlHelper.isLinkAvailable(Globals.setting.profile!.youtube)
                                  ? () {
                                      UrlHelper.launchURL(Globals.setting.profile!.youtube!);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.noServiceProviderIsAvailable),
                          TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const CompanyPickerDialog(),
                                );
                              },
                              child: Text(AppLocalizations.of(context)!.findServiceProvider))
                        ],
                      ),
                    ),
              ListView(
                children: [
                  const Divider(),
                  Container(
                      color: stripe,
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("This app is designed and developed by"),
                                Text(
                                  "(eLexicon Technology Solutions)",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: Image.asset(
                              "assets/images/elexicon.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      )),
                  const Divider(),
                  Builder(
                    builder: (context) {
                      String? appVersionNumber, appVersionSummary;
                      if (Globals.generalSetting.termsAndPolicies != null) {
                        appVersionNumber =
                            "Version: ${Globals.generalSetting.termsAndPolicies!.appVersionNumber} (${Globals.generalSetting.termsAndPolicies!.appVersionName})";
                        appVersionSummary = Globals.generalSetting.termsAndPolicies!.appVersionSummary;
                      } else {
                        appVersionNumber = "Version: 1.0.0";
                        appVersionSummary = "Not Available";
                      }

                      return Container(
                        color: stripe,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appVersionNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            const Text(
                              "Version Summary",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(appVersionSummary!)
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Container(
                    color: stripe,
                    child: GestureDetector(
                        onTap: () {
                          UrlHelper.makePhoneCall("+251911900098");
                        },
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FaIcon(FontAwesomeIcons.phoneFlip),
                            ),
                            VerticalDivider(),
                            Text(
                              "+251911900098",
                            )
                          ],
                        )),
                  ),
                  const Divider(),
                  Container(
                    color: stripe,
                    child: GestureDetector(
                        onTap: () {
                          final Uri url = Uri.parse('https://elexicontech.com');
                          UrlHelper.launchInBrowser(url);
                        },
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FaIcon(FontAwesomeIcons.globe),
                            ),
                            VerticalDivider(),
                            Text(
                              "https://elexicontech.com",
                            )
                          ],
                        )),
                  ),
                  const Divider(),
                  Container(
                    color: stripe,
                    child: GestureDetector(
                        onTap: () {
                          UrlHelper.composeMail(
                            scheme: 'mailto',
                            path: 'calendarsupport@elexicontech.com',
                            subject: 'Event Calendar Feedback',
                          );
                        },
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FaIcon(FontAwesomeIcons.envelope),
                            ),
                            VerticalDivider(),
                            Text(
                              "calendarsupport@elexicontech.com",
                            )
                          ],
                        )),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.facebook),
                        onPressed: UrlHelper.isLinkAvailable("https://www.facebook.com/eLexiconTechnology")
                            ? () {
                                UrlHelper.launchURL("https://www.facebook.com/eLexiconTechnology");
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.twitter),
                        onPressed: UrlHelper.isLinkAvailable(null)
                            ? () {
                                UrlHelper.launchURL(Globals.setting.profile!.twitter!);
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.instagram),
                        onPressed: UrlHelper.isLinkAvailable(null)
                            ? () {
                                UrlHelper.launchURL(Globals.setting.profile!.instagram!);
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.youtube),
                        onPressed: UrlHelper.isLinkAvailable(null)
                            ? () {
                                UrlHelper.launchURL(Globals.setting.profile!.youtube!);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
