import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// FlutterFlow Animation Info
class AnimationInfo {
  const AnimationInfo({
    required this.trigger,
    required this.effects,
    this.loop = false,
    this.reverse = false,
    this.applyInitialState = true,
  });

  final AnimationTrigger trigger;
  final List<Effect> effects;
  final bool loop;
  final bool reverse;
  final bool applyInitialState;
}

enum AnimationTrigger {
  onPageLoad,
  onActionTrigger,
}

/// Extension to apply animations to widgets
extension AnimatedWidgetExtension on Widget {
  Widget animateOnPageLoad(AnimationInfo animationInfo) => animate(
        effects: animationInfo.effects,
        onPlay: (controller) => animationInfo.loop
            ? controller.repeat(reverse: animationInfo.reverse)
            : null,
      );

  Widget animateOnActionTrigger({
    required AnimationController controller,
    required List<Effect> effects,
    bool reverse = false,
  }) =>
      animate(
        controller: controller,
        effects: effects,
      );
}

/// Create common animation effects
class FFAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);

  static List<Effect> fadeIn({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) =>
      [
        FadeEffect(
          delay: delay,
          duration: duration,
          curve: curve,
        ),
      ];

  static List<Effect> slideIn({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) =>
      [
        MoveEffect(
          delay: delay,
          duration: duration,
          curve: curve,
          begin: begin,
          end: end,
        ),
      ];

  static List<Effect> scaleIn({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) =>
      [
        ScaleEffect(
          delay: delay,
          duration: duration,
          curve: curve,
          begin: Offset(begin, begin),
          end: Offset(end, end),
        ),
      ];

  static List<Effect> fadeInSlideUp({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) =>
      [
        FadeEffect(
          delay: delay,
          duration: duration,
          curve: curve,
        ),
        MoveEffect(
          delay: delay,
          duration: duration,
          curve: curve,
          begin: const Offset(0, 20),
          end: Offset.zero,
        ),
      ];

  static List<Effect> shimmer({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 1000),
  }) =>
      [
        ShimmerEffect(
          delay: delay,
          duration: duration,
        ),
      ];

  static List<Effect> bounce({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
  }) =>
      [
        ScaleEffect(
          delay: delay,
          duration: duration,
          curve: Curves.elasticOut,
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
        ),
      ];

  static List<Effect> rotate({
    Duration delay = Duration.zero,
    Duration duration = defaultDuration,
    double begin = 0.0,
    double end = 1.0,
  }) =>
      [
        RotateEffect(
          delay: delay,
          duration: duration,
          begin: begin,
          end: end,
        ),
      ];
}

/// Setup animations for a StatefulWidget
mixin AnimationControllerMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  final animationsMap = <String, AnimationInfo>{};
  final animationControllers = <String, AnimationController>{};

  void setupAnimations(
    Map<String, AnimationInfo> animations,
  ) {
    animationsMap.addAll(animations);
  }

  AnimationController createAnimationController(String key) {
    if (animationControllers.containsKey(key)) {
      return animationControllers[key]!;
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animationControllers[key] = controller;
    return controller;
  }

  @override
  void dispose() {
    for (final controller in animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
