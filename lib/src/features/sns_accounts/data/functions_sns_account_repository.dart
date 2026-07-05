import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_camera/src/core/error/app_exception.dart';
import 'package:flutter_camera/src/core/firebase/firebase_providers.dart';
import 'package:flutter_camera/src/core/models/sns_provider.dart';
// auth featureは実装済み。posting/data/firestore_x_quota_repository.dart や
// posting/presentation/post_compose_controller.dart が同一パスで
// authStateChangesProvider を参照しており、配置は確認済み。
import 'package:flutter_camera/src/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_account_repository.dart';
import 'package:flutter_camera/src/features/sns_accounts/domain/sns_connection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'functions_sns_account_repository.g.dart';

const _snsConnectionsSubcollection = 'snsConnections';

/// [SnsAccountRepository] のCloud Functions/Firestore実装
/// (backend章「参照するFirestoreコレクション」「関数一覧」「Instagram連携設計」
/// 「X連携設計」節準拠)。
class FunctionsSnsAccountRepository implements SnsAccountRepository {
  FunctionsSnsAccountRepository(this._functions, this._firestore, this._uid);

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final String _uid;

  @override
  Stream<List<SnsConnection>> watchConnections() {
    return _firestore
        .collection('users/$_uid/$_snsConnectionsSubcollection')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_connectionFromDoc).toList());
  }

  @override
  Future<void> exchangeInstagramCode({
    required String code,
    required String redirectUri,
  }) {
    return _call('igExchangeToken', {
      'code': code,
      'redirectUri': redirectUri,
    }, provider: SnsProvider.instagram);
  }

  @override
  Future<void> exchangeXCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) {
    return _call('xExchangeToken', {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    }, provider: SnsProvider.x);
  }

  @override
  Future<void> disconnect(SnsProvider provider) {
    return _call('snsDisconnect', {
      'provider': _providerWireValue(provider),
    }, provider: provider);
  }

  Future<void> _call(
    String functionName,
    Map<String, dynamic> data, {
    required SnsProvider provider,
  }) async {
    final callable = _functions.httpsCallable(functionName);
    try {
      await callable.call<Map<String, dynamic>>(data);
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final reason = details is Map ? details['reason'] as String? : null;
      throw SnsAuthException(
        e.message ?? '$functionNameの呼び出しに失敗しました',
        provider: provider,
        // backend章「onCallエラーコード一覧」節: IG_NOT_PROFESSIONAL_ACCOUNT。
        requiresProAccount: reason == 'IG_NOT_PROFESSIONAL_ACCOUNT',
      );
    }
  }

  SnsConnection _connectionFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final provider = _providerFromWire(data['provider'] as String? ?? doc.id);
    final accountType = data['accountType'] as String?;
    return SnsConnection(
      provider: provider,
      status: _statusFromWire(data['status'] as String?),
      username: data['username'] as String?,
      isProAccount: _isProAccount(provider, accountType),
      accountType: accountType,
      updatedAt: _timestampToDate(data['updatedAt']),
    );
  }

  /// backend章「プロアカウント(Business/Creator)判定」節:
  /// `account_type` を大文字小文字を区別せず `BUSINESS` / `MEDIA_CREATOR` と比較する
  /// 判定ロジックと同一の比較を行う。Instagram以外は対象外(常に `null`)。
  bool? _isProAccount(SnsProvider provider, String? accountType) {
    if (provider != SnsProvider.instagram) return null;
    if (accountType == null) return null;
    final normalized = accountType.toUpperCase();
    return normalized == 'BUSINESS' || normalized == 'MEDIA_CREATOR';
  }
}

SnsConnectionStatus _statusFromWire(String? value) => switch (value) {
  'connected' => SnsConnectionStatus.connected,
  'expired' => SnsConnectionStatus.expired,
  'revoked' => SnsConnectionStatus.revoked,
  _ => SnsConnectionStatus.error,
};

SnsProvider _providerFromWire(String value) => switch (value) {
  'x' => SnsProvider.x,
  _ => SnsProvider.instagram,
};

String _providerWireValue(SnsProvider provider) => switch (provider) {
  SnsProvider.instagram => 'instagram',
  SnsProvider.x => 'x',
};

DateTime? _timestampToDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  return null;
}

/// 連携リポジトリ実装のDI(design.md アーキテクチャ章 `snsAccountRepositoryProvider`)。
@Riverpod(keepAlive: true)
SnsAccountRepository snsAccountRepository(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) {
    throw StateError('snsAccountRepository はログイン済みユーザーでのみ利用できます');
  }
  return FunctionsSnsAccountRepository(
    ref.watch(firebaseFunctionsProvider),
    ref.watch(firestoreProvider),
    uid,
  );
}

/// Instagram / X の連携状態購読(design.md アーキテクチャ章 `snsConnectionsProvider`。
/// posting機能(`post_compose_screen.dart`)からも同一パスで参照される)。
@riverpod
Stream<List<SnsConnection>> snsConnections(Ref ref) {
  return ref.watch(snsAccountRepositoryProvider).watchConnections();
}
