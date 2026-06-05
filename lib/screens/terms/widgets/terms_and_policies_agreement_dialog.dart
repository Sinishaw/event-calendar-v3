import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/terms/terms_of_service.dart';
import 'package:flutter/material.dart';

class TermsAndPoliciesAgreementDialog extends StatefulWidget {
  const TermsAndPoliciesAgreementDialog({
    super.key,
    this.tabIndex,
    this.generalTermsVersion,
    this.providerTermsVersion,
  });
  final int? tabIndex;
  final int? generalTermsVersion;
  final int? providerTermsVersion;
  @override
  State<TermsAndPoliciesAgreementDialog> createState() => _TermsAndPoliciesAgreementDialogState();
}

class _TermsAndPoliciesAgreementDialogState extends State<TermsAndPoliciesAgreementDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  String? weekDay;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.addListener(() {});
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle ts = const TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: Colors.blue);
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: ShapeDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    "Terms and Conditions",
                    style: TextStyle(fontSize: 25),
                  ),
                  const Divider(),
                  const Text(
                      "Tap each links below and read them carefully, By clicking the accept button, you "
                      "acknowledge that you have read and agree to all terms.",
                      style: TextStyle(fontSize: 18)),
                  const Divider(),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const TermsOfServicesPage(
                                title: "Terms of Services",
                                tabIndex: 0,
                              );
                            },
                          ),
                        );
                      },
                      child: Text("Application and usage terms", style: ts)),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const TermsOfServicesPage(
                                  title: "Terms of Services",
                                  tabIndex: 1,
                                );
                              },
                            ),
                          );
                        },
                        child: Text("Service provider terms", style: ts)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: const Text(
                            "DECLINE",
                            style: TextStyle(fontSize: 15, color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: const Text(
                            "ACCEPT",
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          ),
                          onPressed: () {
                            Globals.prefs!
                                .setInt(Constants.GeneralTermsAndPoliciesVersion, widget.generalTermsVersion!);
                            Globals.prefs!
                                .setInt(Constants.ServiceProviderTermsAndPoliciesVersion, widget.providerTermsVersion!);
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
