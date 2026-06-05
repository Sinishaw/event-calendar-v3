import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ZoomableImageDialog extends StatefulWidget {
  const ZoomableImageDialog({super.key, this.imageUrl});
  final String? imageUrl;

  @override
  State<ZoomableImageDialog> createState() => _ZoomableImageDialogState();
}

class _ZoomableImageDialogState extends State<ZoomableImageDialog> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 0,
          child: Card(
            shadowColor: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: InteractiveViewer(
              child: GestureDetector(
                  onDoubleTap: () {},
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        ConstrainedBox(constraints: const BoxConstraints(minHeight: 200), child: Container()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 10));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeInExpo);
    controller.addListener(() {});
    controller.forward();
  }
}
