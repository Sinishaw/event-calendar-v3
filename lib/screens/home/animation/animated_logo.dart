import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:flutter/material.dart';

class AnimateLogo extends StatefulWidget {
  const AnimateLogo({super.key});

  @override
  State<AnimateLogo> createState() => _AnimateLogoState();
}

class _AnimateLogoState extends State<AnimateLogo> {
  bool isExpanded = false;
  late Timer timer;
  int animCount = 0;

  _runAnimationLogo() async {
    if (animCount > 3 && timer.isActive) {
      timer.cancel();
    }
    Future.delayed(const Duration(seconds: 2)).then((value) {
      setState(() {
        isExpanded = !isExpanded;
        animCount++;
        Future.delayed(const Duration(seconds: 2)).then((value) {
          setState(() {
            isExpanded = !isExpanded;
          });
        });
      });
    });
  }

  @override
  void initState() {
    _runAnimationLogo();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => _runAnimationLogo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? companyLogo = Globals.prefs!.getString(Constants.CompanyLogo);
    String logo = companyLogo ?? "";

    ///TODO: Configure basic animation parameters from backend(duration, curve, maximum animation count logo size...)
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
      color: Colors.grey.withOpacity(0),
      width: isExpanded ? 80 : 60,
      height: isExpanded ? 80 : 60,
      child: InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: logo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logo,
                    placeholder: (context, url) => ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: Container(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  )
                : Container(),
            // child: Image(
            // ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
