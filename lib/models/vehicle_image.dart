import 'dart:typed_data';

class VehicleImage {
  String? imageUrl; // For network images
  String? localPath; // For picked images on mobile
  Uint8List? webImage; // For picked images on web
  String? imageType; // e.g., "front", "side", "interior"
  bool isNetworkImage;

  VehicleImage({
    this.imageUrl,
    this.localPath,
    this.webImage,
    this.imageType,
    this.isNetworkImage = false,
  }) {
    // Determine if this is a network image
    isNetworkImage = imageUrl != null && imageUrl!.isNotEmpty;
  }
}
