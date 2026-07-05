import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/posting/domain/storage_upload_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_upload_service.g.dart';

/// [StorageUploadService] のFirebase Storage実装
/// (backend章「画像の公開URL(Storage一時公開画像)との組み合わせ」節準拠)。
class FirebaseStorageUploadService implements StorageUploadService {
  FirebaseStorageUploadService(this._storage, this._firestore);

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  @override
  Future<String> uploadPostImage({
    required String uid,
    required String localFilePath,
  }) async {
    // imageId(クライアント生成の一意ID)はFirestoreの `doc()` が
    // ネットワーク往復なしで生成するランダムIDを流用する(uuidパッケージが
    // 直接依存に未追加のため。design.md「冪等性」節が要求する『クライアント生成の
    // 一意なID』という性質はFirestore自動採番IDでも満たされる。coreChangeRequests参照)。
    final imageId = _firestore.collection('posts').doc().id;
    final path = 'users/$uid/postImages/$imageId.jpg';
    try {
      final ref = _storage.ref(path);
      await ref.putFile(
        File(localFilePath),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return path;
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? '画像のアップロードに失敗しました');
    }
  }

  @override
  Future<String> uploadPostVideo({
    required String uid,
    required String localFilePath,
    required String contentType,
  }) async {
    // videoId(クライアント生成の一意ID)は画像と同様にFirestoreの `doc()` を流用する
    // (uploadPostImageと同一方式。coreChangeRequests参照)。
    final videoId = _firestore.collection('posts').doc().id;
    final path = 'users/$uid/postImages/$videoId.mp4';
    try {
      final ref = _storage.ref(path);
      await ref.putFile(
        File(localFilePath),
        SettableMetadata(contentType: contentType),
      );
      return path;
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? '動画のアップロードに失敗しました');
    }
  }
}

@Riverpod(keepAlive: true)
StorageUploadService storageUploadService(Ref ref) {
  return FirebaseStorageUploadService(
    ref.watch(firebaseStorageProvider),
    ref.watch(firestoreProvider),
  );
}
