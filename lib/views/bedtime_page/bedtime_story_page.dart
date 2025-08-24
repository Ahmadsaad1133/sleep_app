import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../constants/fonts.dart';
import '../services/api/api_service.dart';
import 'story.dart';
import 'story_detailed_page.dart';
import 'favorites_page.dart';

class BedtimeStoryPage extends StatefulWidget {
  const BedtimeStoryPage({Key? key}) : super(key: key);

  @override
  State<BedtimeStoryPage> createState() => _BedtimeStoryPageState();
}

class _BedtimeStoryPageState extends State<BedtimeStoryPage>
    with TickerProviderStateMixin {
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();

  bool _loading = false;
  String? _error;
  List<Story> _stories = [];

  late final AnimationController _fadeController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _moodController.dispose();
    _sleepController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateLeftPage() {
    Navigator.of(context).pop();
  }

  Future<void> _generateStories() async {
    FocusScope.of(context).unfocus();
    final mood = _moodController.text.trim();
    final sleepQuality = _sleepController.text.trim();
    if (mood.isEmpty || sleepQuality.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'Please fill in both fields');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _stories = [];
    });

    try {
      final fetched = await ApiService.generateBedtimeStories(
        mood: mood,
        sleepQuality: sleepQuality,
        count: 3,
      );
      if (!mounted) return;
      setState(() => _stories = fetched);
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load stories: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: AppFonts.helveticaRegular,
      fontSize: 16,
      color: Colors.grey.shade300,
    ),
    filled: true,
    fillColor: Colors.black.withOpacity(0.3),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // 1) dreamy night background
              Positioned.fill(
                child: Lottie.asset(
                  'assets/animations/dreamy_night.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),

              // 2) rain overlay
              Positioned.fill(
                child: Lottie.asset(
                  'assets/animations/rainbackground.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),

              // Title row
              Positioned(
                top: h * 0.08,
                left: w * 0.03,
                right: w * 0.03,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateLeftPage,
                      child: SvgPicture.asset(
                        'assets/images/NavigateLeft.svg',
                        color: Colors.white,
                        width: w * 0.1,
                        height: w * 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: w * 0.05),
                        child: Text(
                          'AI Bedtime Stories',
                          style: TextStyle(
                            fontSize: (w * 0.06).clamp(15.0, 32.0),
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            fontFamily: AppFonts.ComfortaaBold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      color: Colors.white,
                      iconSize: w * 0.08,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Animal animation & inputs
              Positioned(
                top: h * 0.20,
                left: w * 0.05,
                right: w * 0.05,
                height: h * 0.30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/animal.json',
                      width: w * 0.9,
                      height: h * 0.25,
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Whisper your evening mood to the stars :',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.016,
                            fontFamily: AppFonts.ComfortaaLight,
                          ),
                        ),
                        SizedBox(height: h * 0.015),
                        TextField(
                          controller: _moodController,
                          decoration:
                          _inputDecoration('How are you feeling tonight?'),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.ComfortaaLight,
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text(
                          'Rate your sleep quality from 1 to 5 :',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.016,
                            fontFamily: AppFonts.ComfortaaLight,
                          ),
                        ),
                        SizedBox(height: h * 0.015),
                        TextField(
                          controller: _sleepController,
                          decoration:
                          _inputDecoration('How did you sleep last night?'),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.ComfortaaLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Generate button
              Positioned(
                bottom: h * 0,
                left: w * 0.2,
                right: w * 0.2,
                height: h * 0.12,
                child: GestureDetector(
                  onTap: _loading ? null : _generateStories,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Lottie.asset(
                          'assets/animations/button.json',
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      ),
                      if (_loading)
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      else
                        Text(
                          'Let the magic work !',
                          style: TextStyle(
                            fontSize: h * 0.016,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.ComfortaaBold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Error message (just above button)
              if (_error != null)
                Positioned(
                  bottom: h * 0.18,
                  left: w * 0.1,
                  right: w * 0.1,
                  child: Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),

              // Stories carousel
              if (_stories.isNotEmpty)
                Positioned(
                  top: h * 0.53,
                  left: 0,
                  right: 0,
                  height: h * 0.35,
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _stories.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, i) {
                        final s = _stories[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryDetailedPage(story: s),
                            ),
                          ),
                          child: Container(
                            margin:
                            EdgeInsets.symmetric(horizontal: w * 0.03),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Lottie.asset(
                                      'assets/animations/spacebackground.json',
                                      fit: BoxFit.cover,
                                      repeat: true,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Hero(
                                        tag: s.imageUrl.isNotEmpty
                                            ? s.imageUrl
                                            : 'placeholder_$i',
                                        child: s.imageUrl.isNotEmpty
                                            ? Image.network(
                                          s.imageUrl,
                                          height: h * 0.18,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                            : Container(
                                          height: h * 0.18,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.deepPurple.shade100,
                                                Colors.deepPurple.shade300,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.auto_stories,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.title,
                                              style: TextStyle(
                                                fontSize: h * 0.020,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily:
                                                AppFonts.ComfortaaLight,
                                              ),
                                            ),
                                            SizedBox(height: h * 0.008),
                                            Text(
                                              s.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: h * 0.014,
                                                fontFamily:
                                                AppFonts.ComfortaaBold,
                                              ),
                                            ),
                                            SizedBox(height: h * 0.008),
                                            Text(
                                              '${s.durationMinutes} min read',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: h * 0.014,
                                                fontFamily:
                                                AppFonts.ComfortaaBold,
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

