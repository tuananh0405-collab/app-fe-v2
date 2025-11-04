enum FaceIdStatus { initial, loading, success, error }

class FaceIdState {
  final FaceIdStatus status;
  final String? message;
  final String? errorMessage;

  const FaceIdState({
    this.status = FaceIdStatus.initial,
    this.message,
    this.errorMessage,
  });

  factory FaceIdState.initial() => const FaceIdState();
  
  factory FaceIdState.loading() => const FaceIdState(status: FaceIdStatus.loading);
  
  factory FaceIdState.success(String message) => FaceIdState(
        status: FaceIdStatus.success,
        message: message,
      );
  
  factory FaceIdState.error(String errorMessage) => FaceIdState(
        status: FaceIdStatus.error,
        errorMessage: errorMessage,
      );

  FaceIdState copyWith({
    FaceIdStatus? status,
    String? message,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FaceIdState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
