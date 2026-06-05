import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:flutter/material.dart';

class SideMenuHeader extends StatelessWidget {
  final double opacity;
  final bool? isDefaultCompany;
  const SideMenuHeader({super.key, required this.opacity, this.isDefaultCompany = true});

  @override
  Widget build(BuildContext context) {
    bool isDefaultCompany = true;
    debugPrint("------ Banner Image: ${Globals.setting.menuHeaderImage}");
    debugPrint("----- Company Name: ${Globals.setting.companyName}");
    ImageProvider bannerImage;
    try {
      if (Globals.setting.menuHeaderImage != null && Globals.setting.menuHeaderImage!.isNotEmpty) {
        bannerImage = CachedNetworkImageProvider(
          Globals.setting.menuHeaderImage!,
        );
        isDefaultCompany = false;
      } else {
        isDefaultCompany = true;
        bannerImage = const AssetImage("assets/images/splash_image.png");
      }
    } catch (e) {
      isDefaultCompany = true;
      bannerImage = const AssetImage("assets/images/splash_image.png");
    }

    return Opacity(
      opacity: opacity,
      child: DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
              image: DecorationImage(image: bannerImage, fit: isDefaultCompany! ? BoxFit.contain : BoxFit.cover)),
          child: const Stack(children: <Widget>[
            Positioned(
                bottom: 12.0,
                left: 16.0,
                child: Text("", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500))),
          ])),
    );
  }
}
