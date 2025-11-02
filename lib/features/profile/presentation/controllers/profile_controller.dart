import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../providers/profile_providers.dart';
import '../state/profile_state.dart';

class ProfileController extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfileUseCase;

  @override
  ProfileState build() {
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    return ProfileState.initial();
  }

  Future<void> loadProfile() async {
    state = ProfileState.loading();

    // Dio automatically adds token via interceptor
    final result = await _getProfileUseCase(NoParams());

    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (profile) => state = ProfileState.loaded(profile),
    );
  }
}
