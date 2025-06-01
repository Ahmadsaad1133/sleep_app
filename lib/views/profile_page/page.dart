import 'package:flutter/material.dart';
import 'base_widget.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseProfileWidget(
      avatar: const AssetImage('assets/images/default_avatar.png'),
      username: 'Your Name',
      bio: 'This is a sample bio. Customize as needed.',
      actions: [],  // No extra action buttons
      content: const Center(
        child: Text(
          'Profile content here',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
