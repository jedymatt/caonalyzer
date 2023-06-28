import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.image,
    this.onTap,
    this.onLongPress,
    this.child,
  });

  final ImageProvider image;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          child: child,
        ),
      ),
    );
  }
}
