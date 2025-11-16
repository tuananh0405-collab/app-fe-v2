import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/faceid_channel.dart';

/// A widget that listens to Face ID success events and navigates to the success page
class FaceIdSuccessHandler extends ConsumerStatefulWidget {
  final Widget child;

  const FaceIdSuccessHandler({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<FaceIdSuccessHandler> createState() => _FaceIdSuccessHandlerState();
}

class _FaceIdSuccessHandlerState extends ConsumerState<FaceIdSuccessHandler> {
  @override
  void initState() {
    super.initState();

    // Listen to Face ID success events
    FaceIdChannel.setOnSuccessListener((successData) {
      if (mounted) {
        final router = GoRouter.of(context);
        final action = successData['action'] as String?;
        final successMessage = successData['success_message'] as String?;
        final userName = successData['user_name'] as String?;

        // Log received data for debugging
        print('🎯 FaceIdSuccessHandler: Received success data - Action: $action, Message: $successMessage, User: $userName');

        // Navigate to success page with parameters
        final queryParams = <String, String>{};
        if (successMessage != null) queryParams['message'] = successMessage;
        if (userName != null) queryParams['userName'] = userName;
        if (action != null) queryParams['action'] = action;

        final uri = Uri(
          path: '/faceid/success',
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        );

        print('🚀 FaceIdSuccessHandler: Navigating to ${uri.toString()}');
        router.go(uri.toString());
      }
    });
    
    // Also listen to Face ID error events and navigate to the same success page to show the message
    FaceIdChannel.setOnErrorListener((errorType, message) {
      if (!mounted) return;
      final router = GoRouter.of(context);
      final queryParams = <String, String>{
        'message': message,
        'action': 'failure',
        'errorType': errorType,
      };

      final uri = Uri(
        path: '/faceid/success',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🚫 FaceIdSuccessHandler: Received error - $errorType: $message');
      router.go(uri.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}