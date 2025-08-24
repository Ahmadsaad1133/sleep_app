import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import '../../constants/fonts.dart';
import 'story_detailed_page.dart';
import 'story.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites', style: TextStyle(fontFamily: AppFonts.AirbnbCerealBook)),
        ),
        body: const Center(
          child: Text('You must be logged in to see favorites.', style: TextStyle(fontFamily: AppFonts.AirbnbCerealBook)),
        ),
      );
    }

    final favStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots();

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Lottie.asset(
              'assets/animations/trainbackground2.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
            Container(color: Colors.black.withOpacity(0.3)),
          ],
        ),
        title: const Text(
          'Your Favorites',
          style: TextStyle(
            fontFamily: AppFonts.ComfortaaBold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/treesbackground.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.05))),
          Positioned(
            top: kToolbarHeight + topPadding,
            left: 0,
            right: 0,
            child: const SizedBox(height: 20, child: ColoredBox(color: Colors.white)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: favStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      fontFamily: AppFonts.AirbnbCerealBook,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No favorites yet.',
                    style: TextStyle(
                      fontFamily: AppFonts.ComfortaaBold,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + topPadding + 30,
                  bottom: 16,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final story = Story(
                    id: doc.id,
                    title: data['title'] as String? ?? 'Untitled',
                    imageUrl: data['imageUrl'] as String? ?? '',
                    durationMinutes: data['durationMinutes'] as int? ?? 0,
                    description: data['description'] as String? ?? '',
                    content: data['content'] as String? ?? '',
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: StoryCard(story: story),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class StoryCard extends StatefulWidget {
  final Story story;
  const StoryCard({Key? key, required this.story}) : super(key: key);

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryDetailedPage(story: widget.story),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hovering
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering ? Colors.amberAccent : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: _hovering ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.story.imageUrl.isNotEmpty) ...[
                  Image.network(
                    widget.story.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ] else ...[
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.indigo],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
                Container(color: Colors.black38),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.title,
                        style: const TextStyle(
                          fontFamily: AppFonts.ComfortaaLight,
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.story.durationMinutes} min',
                          style: const TextStyle(
                            fontFamily: AppFonts.AirbnbCerealBook,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
