import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MusicPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final double position;
  final double duration;
  final ValueChanged<bool> onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onRewind;
  final VoidCallback onForward;

  final double scale;

  const MusicPlayerControls({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onRewind,
    required this.onForward,
    required this.scale,
  });

  String _formatTime(double minutes) {
    final totalSeconds = (minutes * 60).toInt();
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSvgButton(
              assetName: 'assets/images/navigateleftTime.svg',
              onPressed: onRewind,
              width: 39 * scale,
              height: 38 * scale,
            ),
            GestureDetector(
              onTap: () => onPlayPause(!isPlaying),
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
                    decoration: const BoxDecoration(
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
              onPressed: onForward,
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
              onChanged: onSeek,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(position),
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      height: 1.08,
                      color: const Color(0xFFE6E7F2),
                      fontFamily: 'HelveticaNeueRegular',
                    ),
                  ),
                  Text(
                    _formatTime(duration),
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
