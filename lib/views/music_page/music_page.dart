import 'package:flutter/material.dart';
import '/views/music_page/page_base.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseMusicPage(
      title: 'Music Page',
      bodyContent: Center(
        child: Text(
          'Content goes here',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

