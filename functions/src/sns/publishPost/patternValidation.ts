import { HttpsError } from 'firebase-functions/v2/https';
import { db } from '../../lib/admin';

/**
 * retention章「プレミアムパターンのアクセス制御」第3層(Cloud Functions)節 準拠。
 * patterns/{patternId} の存在・所有チェックと isPremium フラグの取得のみを行う。
 * Proプラン判定(resolvePlan)は呼び出し側(snsPublishPost)がbilling/stateを読んで行う。
 */
export interface PatternValidationResult {
  name: string | null;
  isPremium: boolean;
}

export async function validatePattern(uid: string, patternId?: string): Promise<PatternValidationResult> {
  if (!patternId) return { name: null, isPremium: false };

  const snap = await db.doc(`patterns/${patternId}`).get();
  if (!snap.exists) {
    throw new HttpsError('invalid-argument', '指定されたパターンが見つかりません');
  }
  const data = snap.data()!;
  if (!(data.ownerType === 'preset' || data.ownerUid === uid)) {
    throw new HttpsError('permission-denied', '他ユーザーのパターンは指定できません');
  }
  return { name: (data.name as string) ?? null, isPremium: data.isPremium === true };
}
