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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (left != null) left! else Container(),
        if (center != null) center! else Container(),
        if (right != null) right! else Container(),
      ],
    );
  }
}
