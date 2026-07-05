import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions/v2';
import { bucket } from '../lib/admin';

/**
 * data章「Instagram用一時公開画像の公開方法とライフサイクル」節 準拠。
 * 60分毎に igTemp/ プレフィックス配下を走査し、24時間より古いオブジェクトを削除する
 * (snsPublishPost の finally 削除に対する保険。GCSライフサイクルルールとの多層防御)。
 */
const STALE_THRESHOLD_MS = 24 * 60 * 60 * 1000;

export const tempImageCleanup = onSchedule('every 60 minutes', async () => {
  const [files] = await bucket.getFiles({ prefix: 'igTemp/' });
  const cutoff = Date.now() - STALE_THRESHOLD_MS;

  let deleted = 0;
  await Promise.all(
    files.map(async (file) => {
      const timeCreated = file.metadata.timeCreated ? new Date(file.metadata.timeCreated).getTime() : 0;
      if (timeCreated && timeCreated < cutoff) {
        try {
          await file.delete();
          deleted += 1;
        } catch (err) {
          logger.error('tempImageCleanup: 削除失敗', { name: file.name, error: String(err) });
        }
      }
    }),
  );
  logger.info(`tempImageCleanup: ${files.length} 件走査、${deleted} 件削除`);
});
