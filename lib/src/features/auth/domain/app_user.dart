import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/models/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// `users/{uid}` ドキュメントに対応するモデル。
///
/// firebase_auth パッケージの `User` との名前衝突を避けるため
/// `AppUser` とする(別名importは不要)。
///
/// (design.md データモデル・ストレージ・セキュリティルール設計
/// 「Freezedモデル定義」の `app_user.dart` を唯一の正としてそのまま実装する)
@freezed
sealed class AppUser with _$AppUser {
  const factory AppUser({
    /// Firebase Auth UID(ドキュメントIDと同値。Rulesで一致を強制)
    required String uid,
    required String displayName,
    String? photoUrl,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, Object?> json) =>
      _$AppUserFromJson(json);
}
