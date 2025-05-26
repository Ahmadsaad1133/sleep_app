import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MusicPlayerPage extends StatefulWidget {
  final ValueNotifier<bool> onNavbarVisibilityChange;

  const MusicPlayerPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  bool isPlaying = false;
  double position = 0.0;
  final double duration = 45.0;

  @override
  void initState() {
    super.initState();
    widget.onNavbarVisibilityChange.value = false; // hide navbar
  }

  @override
  void dispose() {
    widget.onNavbarVisibilityChange.value = true; // restore navbar
    super.dispose();
  }

  String formatTime(double minutes) {
    final totalSeconds = (minutes * 60).toInt();
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void seek(double toMinutes) => setState(() => position = toMinutes.clamp(0.0, duration));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 375.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF03174C),
      body: Stack(fit: StackFit.expand, children: [
        Positioned(
          top: 0,
          right: 0,
          width: 227,
          height: 312,
          child: SvgPicture.asset(
            'assets/images/nightframe.svg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: 191,
          height: 173,
          child: SvgPicture.asset(
            'assets/images/nightframe2.svg',
            fit: BoxFit.cover,
          ),
        ),

        // Top bar
        Positioned(
          top: 40 * scale,
          left: 20 * scale,
          right: 20 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 55 * scale,
                  height: 55 * scale,
                  decoration: BoxDecoration(
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/removeIcon2.svg',
                      width: 55 * scale,
                      height: 55 * scale,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: SvgPicture.asset(
                      'assets/images/heart.svg',
                      width: 55 * scale,
                      height: 55 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Opacity(
                    opacity: 0.5,
                    child: SvgPicture.asset(
                      'assets/images/download.svg',
                      width: 55 * scale,
                      height: 55 * scale,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: size.height * 0.5 - 40 * scale,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Night Island',
                style: TextStyle(
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                  color: const Color(0xFFE6E7F2),
                  fontFamily: 'HelveticaNeueBold',
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'SLEEP MUSIC',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                  color: const Color(0xFFE6E7F2),
                  fontFamily: 'HelveticaNeueRegular',
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: size.height * 0.62,
          left: 20 * scale,
          right: 20 * scale,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSvgButton(
                    assetName: 'assets/images/navigateleftTime.svg',
                    onPressed: () => seek(position - 0.25),
                    width: 39 * scale,
                    height: 38 * scale,
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isPlaying = !isPlaying),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 82 * scale,
                          height: 87 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBABCC6),
                              width: 10 * scale,
                            ),
                          ),
                        ),
                        Container(
                          width: 67 * scale,
                          height: 67 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 54 * 0.6 * scale,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSvgButton(
                    assetName: 'assets/images/navigaterightTime.svg',
                    onPressed: () => seek(position + 0.25),
                    width: 39 * scale,
                    height: 38 * scale,
                  ),
                ],
              ),
              SizedBox(height: 24 * scale),
              Column(
                children: [
                  Slider(
                    min: 0,
                    max: duration,
                    value: position,
                    onChanged: (v) => setState(() => position = v),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(position),
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w400,
                            height: 1.08,
                            color: const Color(0xFFE6E7F2),
                            fontFamily: 'HelveticaNeueRegular',
                          ),
                        ),
                        Text(
                          formatTime(duration),
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w400,
                            height: 1.08,
                            color: Colors.white,
                            fontFamily: 'HelveticaNeueRegular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSvgButton({
    required String assetName,
    required VoidCallback onPressed,
    double width = 24,
    double height = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: width,
        height: height,
        child: SvgPicture.asset(
          assetName,
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
    );
  }
}
