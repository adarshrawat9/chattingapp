import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecureStorageHelper {
  static final _storage = FlutterSecureStorage();
  static final _firestore = FirebaseFirestore.instance;

  static String _keyForChatRoom(String chatRoomId) => "aes_key_$chatRoomId.secure";

  /// Generate a secure random 32-character AES key
  static Future<String> generateAesKey() async {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(32, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Save AES key locally in secure storage
  static Future<void> saveAesKey(String chatRoomId, String key) async {
    final keyLabel = _keyForChatRoom(chatRoomId);
    await _storage.write(key: keyLabel, value: key);
  }

  /// Get AES key from local secure storage
  static Future<String?> getAesKey(String chatRoomId) async {
    final keyLabel = _keyForChatRoom(chatRoomId);
    return await _storage.read(key: keyLabel);
  }

  /// Delete AES key from secure storage
  static Future<void> deleteAesKey(String chatRoomId) async {
    final keyLabel = _keyForChatRoom(chatRoomId);
    await _storage.delete(key: keyLabel);
  }

  /// Check Firestore for existing AES key, else generate, save to Firestore and local storage
  static Future<void> setupAesKeyIfNeeded(String chatRoomId) async {
    final docRef = _firestore.collection("chatRooms").doc(chatRoomId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data()?['encryptionKey'] == null) {
      // No key found, generate and store
      final newKey = await generateAesKey();

      // Store in Firestore
      await docRef.set({'encryptionKey': newKey}, SetOptions(merge: true));

      // Save locally
      await saveAesKey(chatRoomId, newKey);

      print("🔐 New AES key generated and stored for $chatRoomId");
    } else {
      // Key exists in Firestore, fetch and save locally
      final existingKey = doc.data()!['encryptionKey'];
      await saveAesKey(chatRoomId, existingKey);

      print("🔑 Existing AES key loaded from Firestore for $chatRoomId");
    }
  }
}
