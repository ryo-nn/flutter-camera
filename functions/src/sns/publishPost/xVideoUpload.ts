import { bucket } from '../../lib/admin';
import * as xClient from '../xClient';
import type { XMediaProcessingInfo } from '../xClient';
import {
  computeChunkRanges,
  classifyXProcessingState,
  hasExceededProcessingTimeout,
  X_VIDEO_PROCESSING_DEFAULT_WAIT_SEC,
} from './xChunkedUpload';

/**
 * X動画のチャンクアップロード(INIT→APPEND→FINALIZE→[STATUSポーリング])実行部。
 * 出典: https://docs.x.com/x-api/media/quickstart/media-upload-chunked
 * Storageの恒久オブジェクトを5MBチャンクでストリーム読み出しし、全量をメモリに
 * 展開しない(チャンク単位でのみバッファ化する)。
 *
 * このパイプライン全体は `POST /2/tweets` 呼び出し前(=「送信」の境界より前)の
 * 処理であり、失敗時は呼び出し元(x.ts)がXクォータを返還する対象になる。
 */

export class XMediaProcessingFailedError extends Error {
  constructor(detail?: string) {
    super(`X動画の処理に失敗しました${detail ? `: ${detail}` : ''}`);
  }
}

export class XMediaProcessingTimeoutError extends Error {
  constructor() {
    super('X動画の処理ステータスポーリングがタイムアウトしました(300秒)');
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** Storageオブジェクトの指定バイト範囲(inclusive)のみをメモリに読み込む */
function readChunk(imagePath: string, start: number, end: number): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    bucket
      .file(imagePath)
      .createReadStream({ start, end })
      .on('data', (chunk: Buffer) => chunks.push(chunk))
      .on('end', () => resolve(Buffer.concat(chunks)))
      .on('error', reject);
  });
}

async function pollProcessingUntilDone(
  accessToken: string,
  mediaId: string,
  initialInfo: XMediaProcessingInfo | undefined,
): Promise<void> {
  let info = initialInfo;
  if (!info) return; // processing_infoが無い = 即利用可(公式仕様)

  const start = Date.now();
  for (;;) {
    const action = classifyXProcessingState(info.state);
    if (action === 'done') return;
    if (action === 'failed') throw new XMediaProcessingFailedError(info.error?.message);

    const elapsed = Date.now() - start;
    if (hasExceededProcessingTimeout(elapsed)) throw new XMediaProcessingTimeoutError();

    const waitSec = info.check_after_secs ?? X_VIDEO_PROCESSING_DEFAULT_WAIT_SEC;
    await sleep(waitSec * 1000);

    const status = await xClient.getVideoUploadStatus(accessToken, mediaId);
    info = status.data.processing_info ?? { state: 'succeeded' };
  }
}

/**
 * Storageの動画オブジェクトをチャンクアップロードし、投稿に使えるmedia_idを返す。
 *
 * [contentType] はStorageオブジェクトの実contentType(`video/mp4`。X向けバリデーションで
 * `video/mp4`であることを確認済みの値を呼び出し元から渡す。MOV/MP4のcontentType不整合修正の
 * 一環でINITの`media_type`をハードコードせず実値を参照する)。
 */
export async function uploadVideoChunked(
  accessToken: string,
  imagePath: string,
  totalBytes: number,
  contentType: string,
): Promise<string> {
  const init = await xClient.initVideoUpload(accessToken, totalBytes, contentType);
  const mediaId = init.data.id;

  const ranges = computeChunkRanges(totalBytes);
  for (const range of ranges) {
    const chunk = await readChunk(imagePath, range.start, range.end);
    await xClient.appendVideoChunk(accessToken, {
      mediaId,
      segmentIndex: range.segmentIndex,
      chunk,
    });
  }

  const finalize = await xClient.finalizeVideoUpload(accessToken, mediaId);
  await pollProcessingUntilDone(accessToken, mediaId, finalize.data.processing_info);
  return mediaId;
}
