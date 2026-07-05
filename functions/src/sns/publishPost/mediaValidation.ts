import type { MediaType } from '../types';

/**
 * 動画投稿対応追補: サーバー側バリデーション(クォータ消費前)の純粋ロジック。
 * IG/Xでターゲット別に上限が異なるため、reserveIgFairUse / reserveXQuota の
 * 呼び出し前(クォータ消費前)に各ターゲット処理(instagram.ts / x.ts)から呼び出す。
 *
 * 値の根拠: 依頼元(RYO)が確認済みの各社公式ドキュメントに基づく既定値。
 * - Instagram: durationSec 3〜900秒、fileSizeBytes ≤300MB
 *   (出典: https://developers.facebook.com/docs/instagram-platform/content-publishing)
 * - X: durationSec 0.5〜140秒、fileSizeBytes ≤512MB
 *   (出典: https://docs.x.com/x-api/media/quickstart/media-upload-chunked)
 */

export interface VideoLimits {
  minDurationSec: number;
  maxDurationSec: number;
  maxFileSizeBytes: number;
}

export const IG_VIDEO_LIMITS: VideoLimits = {
  minDurationSec: 3,
  maxDurationSec: 900,
  maxFileSizeBytes: 300 * 1024 * 1024,
};

export const X_VIDEO_LIMITS: VideoLimits = {
  minDurationSec: 0.5,
  maxDurationSec: 140,
  maxFileSizeBytes: 512 * 1024 * 1024,
};

export interface VideoClaim {
  durationSec?: number;
  fileSizeBytes?: number;
}

/**
 * クライアント申告値(durationSec/fileSizeBytes)がターゲット別の動画制約を満たすか検証する。
 * 問題なければnull、問題があればエラーメッセージ(errorCode: MEDIA_VALIDATION_FAILED として
 * finalizeTargetへ渡す想定)を返す。
 */
export function validateVideoClaim(claim: VideoClaim, limits: VideoLimits): string | null {
  const { durationSec, fileSizeBytes } = claim;

  if (typeof durationSec !== 'number' || !Number.isFinite(durationSec)) {
    return 'durationSec は動画投稿では必須です';
  }
  if (durationSec < limits.minDurationSec || durationSec > limits.maxDurationSec) {
    return `durationSec は ${limits.minDurationSec}〜${limits.maxDurationSec} 秒の範囲である必要があります`;
  }

  if (typeof fileSizeBytes !== 'number' || !Number.isFinite(fileSizeBytes) || fileSizeBytes <= 0) {
    return 'fileSizeBytes は動画投稿では必須です';
  }
  if (fileSizeBytes > limits.maxFileSizeBytes) {
    return `fileSizeBytes が上限(${limits.maxFileSizeBytes}バイト)を超えています`;
  }

  return null;
}

export interface StorageObjectMetadata {
  size: number;
  contentType?: string;
}

const IMAGE_CONTENT_TYPE = 'image/jpeg';

/**
 * 動画投稿対応追補(MOV/MP4のcontentType不整合修正): ターゲット別に許可する
 * 動画のStorage `contentType` 一覧。
 * - Instagram: MOV/MP4いずれも受理する(出典:
 *   https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media)。
 * - X: 公式サンプルがMP4のみで確認済み。MOV(`video/quicktime`)の受理可否は
 *   未確認のため許可しない(クライアント側 `VideoTargetRules` でも同様に選択不可にする)。
 */
export const IG_VIDEO_CONTENT_TYPES: readonly string[] = ['video/mp4', 'video/quicktime'];
export const X_VIDEO_CONTENT_TYPES: readonly string[] = ['video/mp4'];

/**
 * クライアント申告値(mediaType/fileSizeBytes)とStorageオブジェクトの実メタデータを
 * 突き合わせ検証する(申告値のみを信用しない)。問題なければnullを返す。
 *
 * [allowedVideoContentTypes] は `mediaType === 'video'` のときのみ使用するターゲット別の
 * 許可contentType一覧(呼び出し元が `IG_VIDEO_CONTENT_TYPES` / `X_VIDEO_CONTENT_TYPES` を
 * 渡す)。省略時は安全側(より狭い許可範囲)の `X_VIDEO_CONTENT_TYPES` を既定値とする。
 */
export function validateStorageObjectMatchesClaim(
  mediaType: MediaType,
  claimedFileSizeBytes: number | undefined,
  actual: StorageObjectMetadata,
  allowedVideoContentTypes: readonly string[] = X_VIDEO_CONTENT_TYPES,
): string | null {
  const expectedContentTypes = mediaType === 'video' ? allowedVideoContentTypes : [IMAGE_CONTENT_TYPE];
  if (!actual.contentType || !expectedContentTypes.includes(actual.contentType)) {
    return `Storageオブジェクトのcontent-type(${actual.contentType ?? 'unknown'})が想定(${expectedContentTypes.join(' / ')})と一致しません`;
  }

  if (mediaType === 'video') {
    if (typeof claimedFileSizeBytes !== 'number' || actual.size !== claimedFileSizeBytes) {
      return 'fileSizeBytesの申告値がStorage上の実サイズと一致しません';
    }
  }

  return null;
}
