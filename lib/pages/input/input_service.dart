import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List?> compressImage(File file) async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return file.readAsBytes();
  }

  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 40,
    format: CompressFormat.jpeg,
  );
  return result;
}
