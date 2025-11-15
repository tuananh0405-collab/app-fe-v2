import 'dart:convert';
import 'dart:typed_data';

/// Represents an uploaded file with its data and metadata
class FFUploadedFile {
  const FFUploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  bool get hasBytes => bytes != null && bytes!.isNotEmpty;

  @override
  String toString() => 'FFUploadedFile('
      'name: $name, '
      'bytes: ${bytes?.length ?? 0}, '
      'height: $height, '
      'width: $width, '
      'blurHash: $blurHash'
      ')';

  Map<String, dynamic> toJson() => {
        'name': name,
        'bytes': bytes != null ? base64Encode(bytes!) : null,
        'height': height,
        'width': width,
        'blurHash': blurHash,
      };

  static FFUploadedFile? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return FFUploadedFile(
      name: json['name'] as String?,
      bytes: json['bytes'] != null ? base64Decode(json['bytes'] as String) : null,
      height: json['height'] as double?,
      width: json['width'] as double?,
      blurHash: json['blurHash'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FFUploadedFile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          bytes == other.bytes &&
          height == other.height &&
          width == other.width &&
          blurHash == other.blurHash;

  @override
  int get hashCode =>
      name.hashCode ^
      bytes.hashCode ^
      height.hashCode ^
      width.hashCode ^
      blurHash.hashCode;
}

/// Serialize FFUploadedFile to JSON string
String? serializeUploadedFile(FFUploadedFile? file) {
  if (file == null) return null;
  return jsonEncode(file.toJson());
}

/// Deserialize FFUploadedFile from JSON string
FFUploadedFile? deserializeUploadedFile(String? fileStr) {
  if (fileStr == null || fileStr.isEmpty) return null;
  try {
    return FFUploadedFile.fromJson(jsonDecode(fileStr) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}
