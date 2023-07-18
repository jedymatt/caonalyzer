import 'package:flutter/material.dart';

class CenterButton extends StatelessWidget {
  const CenterButton({super.key, this.onPressed, this.child});

  final void Function()? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 4,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(36),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class CaptureButton extends StatefulWidget {
  const CaptureButton(
      {super.key, required this.onPressed, this.disabled = false});

  final void Function() onPressed;
  final bool disabled;

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1, end: 1.15).animate(_controller);

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: CenterButton(
        onPressed: widget.disabled
            ? null
            : () {
                _controller.forward(from: 0);
                widget.onPressed();
              },
        child: Icon(
          Icons.camera_alt,
          color: widget.disabled ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
