import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/onboarding/domain/onboarding_grant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_grant_repository.g.dart';

const _onboardingGrantsCollection = 'onboardingGrants';

/// `onboardingGrants/{uid}` の読み取り専用リポジトリ
/// (design.md 第9章「初回同時投稿1回保証(無料枠と別管理)」参照)。
///
/// 消費(`tx.create`)・返還(削除)は `snsPublishPost`(Cloud Functions・Admin SDK)
/// のみが行う(Firestore Security Rules: `allow write: if false`)ため、
/// クライアントは購読のみを実装する。
class OnboardingGrantRepository {
  OnboardingGrantRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// `null` = 保証未消費(ドキュメント不存在。not-found を正常系として読む
  /// 既存 `postUsage` と同型のパターン)。
  Stream<OnboardingGrant?> watch(String uid) {
    return _firestore
        .collection(_onboardingGrantsCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      // ドキュメントIDが uid と一致する契約(design.md「ドキュメントID = uid」)
      // のため、`data.uid` を明示的な引数として渡す必要はないが、フィールドの
      // 欠落に備えてドキュメントIDで補完する(auth/data/firebase_auth_repository.dart
      // の `AppUser.fromJson({...data, 'uid': snapshot.id})` と同型のパターン)。
      return OnboardingGrant.fromJson({...data, 'uid': snapshot.id});
    });
  }
}

@Riverpod(keepAlive: true)
OnboardingGrantRepository onboardingGrantRepository(Ref ref) {
  return OnboardingGrantRepository(ref.watch(firestoreProvider));
}

/// `onboardingGrants/{uid}` 購読(design.md 第9章「プロバイダー追加」表 準拠。
/// `null` = 保証未消費)。S-07(posting feature)がX残回数表示の代わりに
/// 「初回無料」バッジを出す判定に用いる。
///
/// 未ログイン時は常に `null` を返す(グラント判定はログイン後のみ意味を持つ)。
@riverpod
Stream<OnboardingGrant?> onboardingGrant(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(onboardingGrantRepositoryProvider).watch(uid);
}
