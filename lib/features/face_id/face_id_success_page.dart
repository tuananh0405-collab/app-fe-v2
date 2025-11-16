import 'package:flutter/material.dart';

class FaceIdSuccessPage extends StatefulWidget {
  final String? successMessage;
  final String? userName;
  final String? action; // 'register', 'update', 'verify'

  const FaceIdSuccessPage({
    Key? key,
    this.successMessage,
    this.userName,
    this.action,
  }) : super(key: key);

  @override
  State<FaceIdSuccessPage> createState() => _FaceIdSuccessPageState();
}

class _FaceIdSuccessPageState extends State<FaceIdSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _contentController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Icon animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    // Content animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.action) {
      case 'register':
        return 'Congratulations!';
      case 'update':
        return 'Face ID Updated!';
      case 'verify':
        return 'Verification Successful!';
      case 'failure':
        return 'Operation Failed';
      default:
        return 'Success!';
    }
  }

  String _getSubtitle() {
    if (widget.successMessage != null && widget.successMessage!.isNotEmpty) {
      return widget.successMessage!;
    }

    final userName = widget.userName ?? 'You';
    switch (widget.action) {
      case 'register':
        return 'Your Face ID has been registered successfully!\n\nNow $userName can use Face ID for quick attendance and secure access to the app.';
      case 'update':
        return '$userName\'s Face ID has been updated with the latest information.';
      case 'verify':
        return '$userName\'s Face ID has been verified and is working properly.';
      case 'failure':
        // If server provided a message, show it; otherwise show a generic failure
        return widget.successMessage != null && widget.successMessage!.isNotEmpty
            ? widget.successMessage!
            : 'Face ID operation failed. Please try again.';
      default:
        return 'Face ID operation completed successfully!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Success icon with animation
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Content with animation
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _contentSlideAnimation.value),
                    child: Opacity(
                      opacity: _contentFadeAnimation.value,
                      child: Column(
                        children: [
                          // Title
                          Text(
                            _getTitle(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            _getSubtitle(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 60),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate back to settings or home
                                Navigator.of(context).popUntil((route) {
                                  return route.settings.name == '/settings' ||
                                         route.settings.name == '/home' ||
                                         route.isFirst;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}