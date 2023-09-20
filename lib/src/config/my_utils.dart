import 'dart:typed_data';

String uint8ListToHexString(Uint8List uint8List) {
  return uint8List
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join('');
}
