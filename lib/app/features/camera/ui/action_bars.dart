import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    this.left,
    this.right,
    this.center,
  });

  final Widget? left;
  final Widget? right;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (left != null)
            Align(
              alignment: Alignment.centerLeft,
              child: left!,
            ),
          if (center != null) center! else Container(),
          if (right != null)
            Align(
              alignment: Alignment.centerRight,
              child: right!,
            ),
        ],
      ),
    );
  }
}
