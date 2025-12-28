import 'dart:typed_data';
import 'package:chattingapp/core/utils/storage_helper.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:math';

class EncryptionHelper {
  static IV generateRandomIV() {
    final random = Random.secure();
    final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return IV(Uint8List.fromList(ivBytes));
  }

  static Future<String> encryptText(String plainText, String chatRoomId) async {
    final strKey = await SecureStorageHelper.getAesKey(chatRoomId);
    if (strKey == null) throw Exception("AES Key not found");

    final key = Key.fromBase64(strKey);
    final iv = generateRandomIV();
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${encrypted.base64}:${iv.base64}';
  }

  static Future<String> decryptText(String combined, String chatRoomId) async {
    final strKey = await SecureStorageHelper.getAesKey(chatRoomId);
    if (strKey == null) throw Exception("AES Key not found");

    final key = Key.fromBase64(strKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    try {
      if (!combined.contains(':')) return combined;

      final parts = combined.split(':');
      if (parts.length != 2) throw FormatException("Invalid encrypted format");

      final encrypted = Encrypted.fromBase64(parts[0]);
      final iv = IV.fromBase64(parts[1]);

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print(" Decryption failed: $e");
      return "[Encrypted Message]";
    }
  }


}
