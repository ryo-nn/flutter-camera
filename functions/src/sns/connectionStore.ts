import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin';
import type { SnsConnectionStatus, SnsProvider } from './types';

/**
 * data章 `users/{uid}/snsConnections/{provider}` の書き込み(Admin SDK専用)。
 * トークン本体は含まない(表示用メタデータのみ)。
 */

export interface UpsertConnectionParams {
  uid: string;
  provider: SnsProvider;
  username: string;
  externalUserId: string;
  accountType?: string | null;
  scopes?: string[];
  expiresAt?: Date | null;
}

export async function upsertConnectedState(params: UpsertConnectionParams): Promise<void> {
  const { uid, provider, username, externalUserId, accountType, scopes, expiresAt } = params;
  const ref = db.doc(`users/${uid}/snsConnections/${provider}`);
  await ref.set(
    {
      provider,
      status: 'connected' satisfies SnsConnectionStatus,
      username,
      externalUserId,
      accountType: accountType ?? null,
      scopes: scopes ?? [],
      connectedAt: FieldValue.serverTimestamp(),
      expiresAt: expiresAt ? Timestamp.fromDate(expiresAt) : null,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

export async function markConnectionStatus(
  uid: string,
  provider: SnsProvider,
  status: SnsConnectionStatus,
): Promise<void> {
  const ref = db.doc(`users/${uid}/snsConnections/${provider}`);
  await ref.set(
    {
      provider,
      status,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}
