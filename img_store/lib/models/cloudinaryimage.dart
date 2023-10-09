class CloudinaryImage {
  final String assetId;
  final String publicId;
  final String format;
  final int version;
  final String resourceType;
  final String type;
  final String createdAt;
  final int bytes;
  final int width;
  final int height;
  final String folder;
  final String accessMode;
  final String url;
  final String secureUrl;

  CloudinaryImage({
    required this.assetId,
    required this.publicId,
    required this.format,
    required this.version,
    required this.resourceType,
    required this.type,
    required this.createdAt,
    required this.bytes,
    required this.width,
    required this.height,
    required this.folder,
    required this.accessMode,
    required this.url,
    required this.secureUrl,
  });

  factory CloudinaryImage.fromJson(Map<String, dynamic> json) {
    return CloudinaryImage(
      assetId: json['asset_id'],
      publicId: json['public_id'],
      format: json['format'],
      version: json['version'],
      resourceType: json['resource_type'],
      type: json['type'],
      createdAt: json['created_at'],
      bytes: json['bytes'],
      width: json['width'],
      height: json['height'],
      folder: json['folder'],
      accessMode: json['access_mode'],
      url: json['url'],
      secureUrl: json['secure_url'],
    );
  }
}
