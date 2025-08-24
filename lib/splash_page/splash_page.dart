import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/assets.dart';
import '../routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showError = false;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Moved precache to here where context is safe to use
    if (!_imageLoaded && !_showError) {
      _precacheImage();
    }
  }

  void _precacheImage() {
    precacheImage(
      AssetImage(AppAssets.splashImage),
      context,
    ).then((_) {
      if (mounted) setState(() => _imageLoaded = true);
    }).catchError((error) {
      debugPrint('Image precache error: $error');
      if (mounted) setState(() => _showError = true);
    });
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        isLoggedIn ? Routes.home7 : Routes.home,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _showError
            ? _buildErrorWidget()
            : _imageLoaded
            ? _buildImageWidget()
            : _buildLoadingPlaceholder(),
      ),
    );
  }

  Widget _buildImageWidget() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.asset(
        AppAssets.splashImage,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image loading error: $error');
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),
        const SizedBox(height: 16),
        const Text(
          'Splash image failed to load',
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 8),
        Text(
          'Path: ${AppAssets.splashImage}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}