import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'faceid_channel.dart';
import 'features/auth/providers/auth_providers.dart';

class FaceIdPage extends ConsumerStatefulWidget {
  const FaceIdPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FaceIdPage> createState() => _FaceIdPageState();
}

class _FaceIdPageState extends ConsumerState<FaceIdPage> {
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    FaceIdChannel.onRegistered.listen((success) {
      if (!mounted) return;
      setState(() {
        _status = success ? 'Registered successfully' : 'Registration failed';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_status)));
    });
  }

  Future<void> _openRegister() async {
    // ✅ Lấy user ID từ login state
    final loginState = ref.read(loginControllerProvider);
    final userId = loginState.user?.id;
    
    if (userId == null || userId.isEmpty) {
      setState(() {
        _status = 'Error: User not logged in';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
      }
      return;
    }
    
    final started = await FaceIdChannel.registerFace(userId: userId);
    if (!mounted) return;
    setState(() {
      _status = started ? 'Register screen opened' : 'Failed to open native register screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face ID')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_status),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openRegister,
              child: const Text('Mở màn đăng ký Face'),
            ),
          ],
        ),
      ),
    );
  }
}
