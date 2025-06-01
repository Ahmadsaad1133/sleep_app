import 'package:flutter/material.dart';
class BaseProfileWidget extends StatelessWidget {
  final ImageProvider avatar;

  final String username;

  final String? bio;

  final List<Widget>? actions;

  final Widget? content;

  final Color headerBackgroundColor;

  const BaseProfileWidget({
    Key? key,
    required this.avatar,
    required this.username,
    this.bio,
    this.actions,
    this.content,
    this.headerBackgroundColor = const Color(0xFF03174C),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          if (content != null) Expanded(child: content!),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: headerBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: avatar,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bio != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        bio!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: 8),
              Row(children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
