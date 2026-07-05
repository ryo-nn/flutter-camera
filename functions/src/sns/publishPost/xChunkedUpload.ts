/**
 * X動画チャンクアップロードの純粋ロジック(チャンク境界計算・処理ステータス判定)。
 * 出典: https://docs.x.com/x-api/media/quickstart/media-upload-chunked
 * StorageからのAPPEND読み出しは5MB固定チャンクとし、全量をメモリに載せない
 * (Storageの createReadStream({start, end}) によるバイト範囲読み出しと組み合わせて使う。
 * 実際のI/Oは xVideoUpload.ts が担う)。
 */

export const X_VIDEO_CHUNK_SIZE_BYTES = 5 * 1024 * 1024; // 5MB

export interface ChunkRange {
  segmentIndex: number;
  /** 読み出し開始バイトオフセット(inclusive) */
  start: number;
  /** 読み出し終了バイトオフセット(inclusive。Storage createReadStreamのend仕様に合わせる) */
  end: number;
}

/** 総バイト数からAPPENDチャンクの境界(segment_index・読み出し範囲)を計算する */
export function computeChunkRanges(
  totalBytes: number,
  chunkSizeBytes: number = X_VIDEO_CHUNK_SIZE_BYTES,
): ChunkRange[] {
  if (!Number.isFinite(totalBytes) || totalBytes <= 0 || chunkSizeBytes <= 0) return [];

  const ranges: ChunkRange[] = [];
  let start = 0;
  let segmentIndex = 0;
  while (start < totalBytes) {
    const end = Math.min(start + chunkSizeBytes, totalBytes) - 1;
    ranges.push({ segmentIndex, start, end });
    start = end + 1;
    segmentIndex += 1;
  }
  return ranges;
}

export type XProcessingAction = 'done' | 'failed' | 'continue';

/** processing_info.state から次アクションを判定する(succeeded=完了/failed=失敗/それ以外=継続) */
export function classifyXProcessingState(state: string): XProcessingAction {
  if (state === 'succeeded') return 'done';
  if (state === 'failed') return 'failed';
  return 'continue';
}

/** STATUSポーリングの全体タイムアウト(秒指定なしのデフォルト待機と合わせて300秒) */
export const X_VIDEO_PROCESSING_TIMEOUT_MS = 300_000;
export const X_VIDEO_PROCESSING_DEFAULT_WAIT_SEC = 5;

/** 経過時間が全体タイムアウト(300秒)を超えたかを判定する */
export function hasExceededProcessingTimeout(elapsedMs: number): boolean {
  return elapsedMs >= X_VIDEO_PROCESSING_TIMEOUT_MS;
}
