import 'package:flutter/material.dart';

class ModernMeditationCard extends StatelessWidget {
  final String imageUrl, title, subtitle;
  final VoidCallback onPlay;
  final double width, height;

  const ModernMeditationCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onPlay,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              ),
              const SizedBox(height: 4),
              Text(
                  subtitle,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14
                  )
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 50,
          child: GestureDetector(
            onTap: onPlay,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle
              ),
              child: const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.black87
              ),
            ),
          ),
        ),
      ]),
    );
  }
}