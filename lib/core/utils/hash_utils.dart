import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashUtils {
  static String hashPassword(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }
}
