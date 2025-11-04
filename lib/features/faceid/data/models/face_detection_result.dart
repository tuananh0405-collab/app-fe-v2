class FaceDetectionResult {
  final bool hasFace;
  final bool isSpoof;
  final double confidence;
  final String? message;

  const FaceDetectionResult({
    required this.hasFace,
    required this.isSpoof,
    required this.confidence,
    this.message,
  });
}
