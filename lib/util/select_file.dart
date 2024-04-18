import 'package:image_picker/image_picker.dart';

Future<XFile?> getImagenByGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image;
}

Future<XFile?> getImagenByCamera() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  return image;
}

Future<XFile?> getVideoByGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickVideo(source: ImageSource.gallery);
  return image;
}

Future<XFile?> getVideoByCamera() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickVideo(source: ImageSource.camera);
  return image;
}