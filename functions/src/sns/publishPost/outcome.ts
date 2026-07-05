import { HttpsError } from 'firebase-functions/v2/https';
import type { FailureKind } from '../../lib/errors';

/**
 * ターゲット(Instagram/X)ごとの処理結果を表す内部モデル。
 * 'alreadyRunning' は X_ALREADY_RUNNING / POST_ALREADY_PROCESSING 用で、
 * design.md「onCallエラーコード一覧」の規定どおりFirestoreへの書き込みを行わない
 * (ターゲット状態は変更しない。UIは実行中表示のまま待機)。
 */
export type TargetOutcome =
  | { kind: 'succeeded'; publishedId: string }
  | { kind: 'failed'; reason: string; failureKind: FailureKind; message: string; extra?: Record<string, unknown> }
  | { kind: 'alreadyRunning' };

export function succeededOutcome(publishedId: string): TargetOutcome {
  return { kind: 'succeeded', publishedId };
}

export function failedOutcome(
  reason: string,
  failureKind: FailureKind,
  message: string,
  extra?: Record<string, unknown>,
): TargetOutcome {
  return { kind: 'failed', reason, failureKind, message, extra };
}

/**
 * quota章「failureKindの割当」+ backend章リトライ方針表 準拠のreason→failureKindデフォルト値。
 * 個別の呼び出し元が明示的にfailureKindを指定するため、本マップは
 * HttpsErrorから outcome を再構成する際のフォールバックとして使う。
 */
const REASON_FAILURE_KIND: Record<string, FailureKind> = {
  IG_QUOTA_EXCEEDED: 'retryable',
  IG_CONTAINER_TIMEOUT: 'retryable',
  IG_CONTAINER_ERROR: 'retryable',
  IG_FAIR_USE_EXCEEDED: 'retryable',
  IG_PUBLISH_FAILED: 'retryable',
  X_QUOTA_EXCEEDED: 'retryable',
  X_URL_NOT_ALLOWED: 'retryable',
  X_PHONE_VERIFICATION_REQUIRED: 'retryable',
  FREE_QUOTA_DEVICE_LIMIT: 'permanent',
  X_MEDIA_UPLOAD_FAILED: 'retryable',
  X_POST_FAILED: 'retryable',
  TOKEN_EXPIRED: 'permanent',
  UNKNOWN_RESULT: 'unknown',
  PATTERN_PREMIUM_REQUIRED: 'retryable',
  // 動画対応追補: X_URL_NOT_ALLOWEDと同様、クライアント側の入力(申告値/メディア実体)を
  // 修正すれば解消し得る消費前バリデーション失敗のためretryable扱い
  MEDIA_VALIDATION_FAILED: 'retryable',
};

export function outcomeFromUnknownError(
  err: unknown,
  fallbackReason: string,
  fallbackMessage: string,
): TargetOutcome {
  if (err instanceof HttpsError) {
    const details = err.details as { reason?: string } & Record<string, unknown> | undefined;
    if (details?.reason === 'X_ALREADY_RUNNING' || details?.reason === 'POST_ALREADY_PROCESSING') {
      return { kind: 'alreadyRunning' };
    }
    const reason = details?.reason ?? fallbackReason;
    const kind = REASON_FAILURE_KIND[reason] ?? 'unknown';
    return failedOutcome(reason, kind, err.message, details);
  }
  return failedOutcome(fallbackReason, 'unknown', err instanceof Error ? err.message : fallbackMessage);
}
