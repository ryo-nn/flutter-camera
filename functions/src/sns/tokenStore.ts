import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import { decryptToken, encryptToken } from '../lib/kms';
import type { SnsProvider } from './types';

/**
 * data章 `snsTokens/{uid}_{provider}` の読み書き(Admin SDK専用。クライアントは
 * Security Rulesで全面拒否)。暗号化方式はbackend章「ユーザーのアクセストークン
 * 保管と暗号化」節に準拠(lib/kms.ts参照)。
 */

function tokenDocId(uid: string, provider: SnsProvider): string {
  return `${uid}_${provider}`;
}

function aadFor(uid: string, provider: SnsProvider): string {
  return `${uid}:${provider}`;
}

export interface SaveTokensParams {
  uid: string;
  provider: SnsProvider;
  accessToken: string;
  refreshToken?: string | null;
  tokenType?: string;
  scopes?: string[];
  expiresAt?: Date | null;
  externalUserId?: string;
}

export async function saveTokens(params: SaveTokensParams): Promise<void> {
  const { uid, provider, accessToken, refreshToken, tokenType, scopes, expiresAt, externalUserId } = params;
  const aad = aadFor(uid, provider);
  const encAccess = await encryptToken(accessToken, aad);

  let refreshTokenCiphertext: string | null = null;
  if (refreshToken) {
    const encRefresh = await encryptToken(refreshToken, aad);
    refreshTokenCiphertext = encRefresh.ciphertext;
  }

  const ref = db.doc(`snsTokens/${tokenDocId(uid, provider)}`);
  const existing = await ref.get();

  const data: Record<string, unknown> = {
    uid,
    provider,
    accessTokenCiphertext: encAccess.ciphertext,
    refreshTokenCiphertext,
    tokenType: tokenType ?? 'bearer',
    scopes: scopes ?? [],
    expiresAt: expiresAt ? Timestamp.fromDate(expiresAt) : null,
    encKeyRef: encAccess.keyVersion,
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (!existing.exists) {
    data.createdAt = FieldValue.serverTimestamp();
  }
  if (provider === 'instagram' && externalUserId) data.igUserId = externalUserId;
  if (provider === 'x' && externalUserId) data.xUserId = externalUserId;

  await ref.set(data, { merge: true });
}

export interface DecryptedToken {
  accessToken: string;
  doc: FirebaseFirestore.DocumentData;
}

export async function getDecryptedToken(uid: string, provider: SnsProvider): Promise<DecryptedToken | null> {
  const ref = db.doc(`snsTokens/${tokenDocId(uid, provider)}`);
  const snap = await ref.get();
  if (!snap.exists) return null;
  const data = snap.data()!;
  const accessToken = await decryptToken(data.accessTokenCiphertext, aadFor(uid, provider));
  return { accessToken, doc: data };
}

export async function getDecryptedRefreshToken(uid: string, provider: SnsProvider): Promise<string | null> {
  const ref = db.doc(`snsTokens/${tokenDocId(uid, provider)}`);
  const snap = await ref.get();
  if (!snap.exists) return null;
  const data = snap.data()!;
  if (!data.refreshTokenCiphertext) return null;
  return decryptToken(data.refreshTokenCiphertext, aadFor(uid, provider));
}

export async function updateAccessToken(params: {
  uid: string;
  provider: SnsProvider;
  accessToken: string;
  refreshToken?: string | null;
  expiresAt: Date;
}): Promise<void> {
  const { uid, provider, accessToken, refreshToken, expiresAt } = params;
  const aad = aadFor(uid, provider);
  const encAccess = await encryptToken(accessToken, aad);
  const update: Record<string, unknown> = {
    accessTokenCiphertext: encAccess.ciphertext,
    encKeyRef: encAccess.keyVersion,
    expiresAt: Timestamp.fromDate(expiresAt),
    updatedAt: FieldValue.serverTimestamp(),
  };
  // X: レスポンスにrefresh_tokenが含まれていたら必ず旧値を上書き保存(ローテーション防御)
  if (refreshToken) {
    const encRefresh = await encryptToken(refreshToken, aad);
    update.refreshTokenCiphertext = encRefresh.ciphertext;
  }
  await db.doc(`snsTokens/${tokenDocId(uid, provider)}`).set(update, { merge: true });
}

export async function deleteTokens(uid: string, provider: SnsProvider): Promise<void> {
  await db.doc(`snsTokens/${tokenDocId(uid, provider)}`).delete();
}
