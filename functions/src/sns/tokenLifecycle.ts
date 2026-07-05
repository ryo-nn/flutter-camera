import { deleteTokens } from './tokenStore';
import { markConnectionStatus } from './connectionStore';
import type { SnsProvider } from './types';

/**
 * backend章「トークン失効時の再連携フロー」節 準拠。
 * トークン無効系エラーを検知した際に呼び出し、snsTokensを削除しsnsConnectionsを
 * 'expired' にする(再連携は新規連携と同一の関数で行う想定)。
 */
export async function handleTokenExpired(uid: string, provider: SnsProvider): Promise<void> {
  await deleteTokens(uid, provider);
  await markConnectionStatus(uid, provider, 'expired');
}

interface ApiErrorLike {
  status?: number;
  body?: { error?: { code?: number; type?: string } };
}

/**
 * Instagram(Graph API)のトークン無効系エラー判定。
 * 出典: Meta Graph APIのエラーコード190("Invalid OAuth access token")は
 * 広く知られた慣行的な判定基準。401応答も無効トークンとして扱う。
 */
export function isIgTokenInvalidError(err: unknown): boolean {
  const e = err as ApiErrorLike;
  if (!e) return false;
  if (e.status === 401) return true;
  return e.body?.error?.code === 190;
}

/** X APIのトークン無効系エラー判定(401応答を無効トークンとして扱う) */
export function isXTokenInvalidError(err: unknown): boolean {
  const e = err as ApiErrorLike;
  return e?.status === 401;
}
