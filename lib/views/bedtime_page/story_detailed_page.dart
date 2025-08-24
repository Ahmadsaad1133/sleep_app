import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/fonts.dart';
import 'story.dart';

class StoryDetailedPage extends StatefulWidget {
  final Story story;

  const StoryDetailedPage({Key? key, required this.story}) : super(key: key);

  @override
  _StoryDetailedPageState createState() => _StoryDetailedPageState();
}

class _StoryDetailedPageState extends State<StoryDetailedPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;
  late final List<String> _chars;
  int _current = 0;

  // Favorites
  bool _isFavorite = false;
  late final CollectionReference _favRef;

  String get _docKey => Uri.encodeComponent(widget.story.title);

  @override
  void initState() {
    super.initState();

    // Initialize Firestore reference for this user's favorites
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');

    // Split the full story into characters once
    _chars = widget.story.content.split('');

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_scaleCtrl);

    // Check initial favorite status
    _checkIfFavorite();

    // Kick off the typewriter animation
    _startTyping();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final doc = await _favRef.doc(_docKey).get();
      if (mounted) setState(() => _isFavorite = doc.exists);
    } catch (e) {
      // handle error if needed
    }
  }

  Future<void> _toggleFavorite() async {
    final docRef = _favRef.doc(_docKey);
    if (_isFavorite) {
      await docRef.delete();
    } else {
      await docRef.set({
        'title': widget.story.title,
        'description': widget.story.description,
        'imageUrl': widget.story.imageUrl,
        'content': widget.story.content,
        'durationMinutes': widget.story.durationMinutes,
      });
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _startTyping() async {
    for (var i = 1; i <= _chars.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => _current = i);
      _fadeCtrl.forward(from: 0);
      _scaleCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final before = _current > 1 ? _chars.take(_current - 1).join() : '';
    final currentChar = _current > 0 ? _chars[_current - 1] : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.title,
          style: const TextStyle(
            fontFamily: AppFonts.AirbnbCerealBook,
          ),
        ),
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Lottie background animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/trainbackground.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          // Content overlay
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.imageUrl.startsWith('http'))
                  Hero(
                    tag: s.imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        s.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppFonts.AirbnbCerealBook,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: AppFonts.AirbnbCerealBook,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (_, __) {
                    return RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.white,
                          fontFamily: AppFonts.AirbnbCerealBook,
                        ),
                        children: [
                          TextSpan(text: before),
                          WidgetSpan(
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_fadeCtrl, _scaleCtrl]),
                              builder: (_, __) {
                                return Transform.scale(
                                  scale: _scaleAnim.value,
                                  child: Opacity(
                                    opacity: _fadeCtrl.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueGrey.withOpacity(0.3),
                                      ),
                                      child: Text(currentChar),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Estimated: ${s.durationMinutes} min read',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
