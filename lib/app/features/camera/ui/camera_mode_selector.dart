import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:flutter/material.dart';

class CameraModePage extends StatefulWidget {
  const CameraModePage({
    super.key,
    this.initialDisplayMode = CameraDisplayMode.photo,
    required this.availableModes,
    required this.onChangeCameraMode,
  });

  final CameraDisplayMode initialDisplayMode;
  final List<CameraDisplayMode> availableModes;
  final void Function(CameraDisplayMode displayMode) onChangeCameraMode;

  @override
  State<CameraModePage> createState() => _CameraModePageState();
}

class _CameraModePageState extends State<CameraModePage> {
  late PageController _pageController;

  int _index = 0;

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(viewportFraction: 0.25, initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: (index) {
                final cameraMode = widget.availableModes[index];
                widget.onChangeCameraMode(cameraMode);
                setState(() {
                  _index = index;
                });
              },
              itemCount: widget.availableModes.length,
              itemBuilder: ((context, index) {
                final cameraMode = widget.availableModes[index];
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: index == _index ? 1 : 0.2,
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        cameraMode.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black,
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        )
      ],
    );
  }
}
