import { logger } from 'firebase-functions/v2';
import { bucket } from '../../lib/admin';
import type { MediaType } from '../types';

/**
 * data章「Instagram用一時公開画像の公開方法とライフサイクル」節 準拠。
 * 動画対応追補: mediaTypeに応じて拡張子を切り替える(image→.jpg / video→.mp4)。
 * igTemp/ プレフィックスはクライアントアクセス全面禁止のままで、tempImageCleanup
 * のonSchedule走査も拡張子を問わずprefix一致で処理するため影響しない。
 */

function igTempExt(mediaType: MediaType): string {
  return mediaType === 'video' ? 'mp4' : 'jpg';
}

function igTempPath(uid: string, postId: string, mediaType: MediaType): string {
  return `igTemp/${uid}/${postId}.${igTempExt(mediaType)}`;
}

export async function copyToIgTemp(
  uid: string,
  postId: string,
  imagePath: string,
  mediaType: MediaType,
): Promise<void> {
  const source = bucket.file(imagePath);
  const dest = bucket.file(igTempPath(uid, postId, mediaType));
  await source.copy(dest);
}

/** 有効期限60分のV4署名付きURLを発行する */
export async function getIgTempSignedUrl(uid: string, postId: string, mediaType: MediaType): Promise<string> {
  const file = bucket.file(igTempPath(uid, postId, mediaType));
  const [url] = await file.getSignedUrl({
    version: 'v4',
    action: 'read',
    expires: Date.now() + 60 * 60 * 1000,
  });
  return url;
}

/**
 * 投稿完了時(succeeded/failed)にfinallyブロックから必ず呼ぶ。削除失敗は
 * onSchedule(tempImageCleanup)+GCSライフサイクルルールの多層防御で回収されるため
 * ここでは例外を握りつぶしログのみ残す。
 */
export async function deleteIgTempFile(uid: string, postId: string, mediaType: MediaType): Promise<void> {
  const file = bucket.file(igTempPath(uid, postId, mediaType));
  try {
    await file.delete();
  } catch (err) {
    logger.warn('igTemp一時ファイルの削除に失敗(onScheduleのtempImageCleanupが保険として回収)', {
      uid,
      postId,
      error: String(err),
    });
  }
}
