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
  Widget _buildLogoPlaceholder({required double size, required IconData icon, required ThemeData theme}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.06),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.45,
          color: theme.colorScheme.secondary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6, left: 4),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 12,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required dynamic icon,
    required String? url,
  }) {
    if (!UrlHelper.isLinkAvailable(url)) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => UrlHelper.launchURL(url!),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: FaIcon(
            icon,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutApp),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // SECTION 1: Service Provider
            _buildSectionHeader(AppLocalizations.of(context)!.serviceProvider, theme),
            Globals.setting.profile != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cover Image (Banner)
                      if (UrlHelper.isLinkAvailable(Globals.setting.profile!.iUrl))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: Globals.setting.profile!.iUrl!,
                              height: height / 6.5,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: height / 6.5,
                                color: theme.primaryColor.withOpacity(0.05),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: height / 6.5,
                                color: theme.primaryColor.withOpacity(0.05),
                                child: const Icon(Icons.broken_image_rounded, size: 32),
                              ),
                            ),
                          ),
                        ),

                      // Provider Brand Card
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (UrlHelper.isLinkAvailable(Globals.setting.logo))
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: theme.dividerColor.withOpacity(0.12),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: Globals.setting.logo!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => _buildLogoPlaceholder(size: 48, icon: Icons.business_rounded, theme: theme),
                                      errorWidget: (context, url, error) => _buildLogoPlaceholder(size: 48, icon: Icons.broken_image_rounded, theme: theme),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Delivered to you by",
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.secondary.withOpacity(0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      Globals.setting.companyName ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Provider Description Card
                      if (Globals.setting.profile!.description != null && Globals.setting.profile!.description!.isNotEmpty)
                        Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: theme.cardColor.withOpacity(isDark ? 0.25 : 0.45),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.08), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      "About the Provider",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Globals.setting.profile!.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Contact Details Card
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (UrlHelper.isLinkAvailable(Globals.setting.profile!.phone))
                                _buildContactTile(
                                  icon: Icons.phone_android_rounded,
                                  title: Globals.setting.profile!.phone!,
                                  onTap: () => UrlHelper.makePhoneCall(Globals.setting.profile!.phone!),
                                ),
                              if (UrlHelper.isLinkAvailable(Globals.setting.profile!.phone) &&
                                  (UrlHelper.isLinkAvailable(Globals.setting.profile!.website) ||
                                   UrlHelper.isLinkAvailable(Globals.setting.profile!.email)))
                                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1), indent: 44),
                              if (UrlHelper.isLinkAvailable(Globals.setting.profile!.website))
                                _buildContactTile(
                                  icon: Icons.language_rounded,
                                  title: Globals.setting.profile!.website!,
                                  onTap: () => UrlHelper.launchURL(Globals.setting.profile!.website!),
                                ),
                              if (UrlHelper.isLinkAvailable(Globals.setting.profile!.website) &&
                                  UrlHelper.isLinkAvailable(Globals.setting.profile!.email))
                                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1), indent: 44),
                              if (UrlHelper.isLinkAvailable(Globals.setting.profile!.email))
                                _buildContactTile(
                                  icon: Icons.mail_outline_rounded,
                                  title: Globals.setting.profile!.email!,
                                  onTap: () => UrlHelper.launchURL("mailto:${Globals.setting.profile!.email!}"),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Social Media Row
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              icon: FontAwesomeIcons.facebook,
                              url: Globals.setting.profile!.facebook,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.xTwitter,
                              url: Globals.setting.profile!.twitter,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.instagram,
                              url: Globals.setting.profile!.instagram,
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.youtube,
                              url: Globals.setting.profile!.youtube,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Column(
                        children: [
                          Icon(Icons.business_rounded, size: 40, color: theme.disabledColor.withOpacity(0.4)),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.noServiceProviderIsAvailable,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const CompanyPickerDialog(),
                              );
                            },
                            icon: const Icon(Icons.search_rounded, size: 16),
                            label: Text(AppLocalizations.of(context)!.findServiceProvider, style: const TextStyle(fontSize: 12.5)),
                          )
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 6),

            // SECTION 2: Developer
            _buildSectionHeader(AppLocalizations.of(context)!.developer, theme),

            // Developer Brand & Version Card
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                "assets/images/elexicon.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Designed & Developed by",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "eLexicon Technology Solutions",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        String appVersionNumber, appVersionSummary;
                        if (Globals.generalSetting.termsAndPolicies != null) {
                          appVersionNumber =
                              "Version ${Globals.generalSetting.termsAndPolicies!.appVersionNumber} (${Globals.generalSetting.termsAndPolicies!.appVersionName})";
                          appVersionSummary = Globals.generalSetting.termsAndPolicies!.appVersionSummary ?? "No summary available.";
                        } else {
                          appVersionNumber = "Version 1.0.0";
                          appVersionSummary = "No version summary available.";
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.system_update_rounded, size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  appVersionNumber,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appVersionSummary,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Developer Contact Card
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildContactTile(
                      icon: Icons.phone_android_rounded,
                      title: "+251911900098",
                      onTap: () => UrlHelper.makePhoneCall("+251911900098"),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1), indent: 44),
                    _buildContactTile(
                      icon: Icons.language_rounded,
                      title: "https://elexicontech.com",
                      onTap: () {
                        final Uri url = Uri.parse('https://elexicontech.com');
                        UrlHelper.launchInBrowser(url);
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1), indent: 44),
                    _buildContactTile(
                      icon: Icons.mail_outline_rounded,
                      title: "calendarsupport@elexicontech.com",
                      onTap: () => UrlHelper.composeMail(
                        scheme: 'mailto',
                        path: 'calendarsupport@elexicontech.com',
                        subject: 'Event Calendar Feedback',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Developer Social Media Row
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: FontAwesomeIcons.facebook,
                    url: "https://www.facebook.com/eLexiconTechnology",
                  ),
                  _buildSocialButton(
                    icon: FontAwesomeIcons.xTwitter,
                    url: "https://x.com/eLexiconTech",
                  ),
                  _buildSocialButton(
                    icon: FontAwesomeIcons.linkedin,
                    url: "https://www.linkedin.com/company/elexicon-technology-solutions",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
