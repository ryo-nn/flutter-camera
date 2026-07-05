import * as igClient from '../igClient';

/**
 * backend章「投稿フロー(コンテナ作成→ステータス確認→publish)」節 準拠のポーリング設計。
 * 画像: まず5秒間隔で最大60秒確認し、未完なら60秒間隔で最大5分まで継続する。
 * 動画対応追補: REELSコンテナは10秒間隔・最大300秒の固定ポーリングとする(依頼元確認済み)。
 * いずれもERROR/EXPIREDは即時失敗、タイムアウト超過はタイムアウト失敗として打ち切る。
 */

export class IgContainerStatusError extends Error {
  constructor(public readonly statusCode: string) {
    super(`Instagram container status: ${statusCode}`);
  }
}

export class IgContainerTimeoutError extends Error {
  constructor() {
    super('Instagram container status polling timed out');
  }
}

const FIRST_PHASE_INTERVAL_MS = 5_000;
const FIRST_PHASE_DURATION_MS = 60_000;
const SECOND_PHASE_INTERVAL_MS = 60_000;
const TOTAL_TIMEOUT_MS = 5 * 60_000;

export const VIDEO_POLL_INTERVAL_MS = 10_000;
export const VIDEO_POLL_TOTAL_TIMEOUT_MS = 5 * 60_000;

export type ContainerPollAction = 'done' | 'error' | 'continue';

/** status_code から次アクションを判定する純粋ロジック(FINISHED/PUBLISHED=完了、ERROR/EXPIRED=即時失敗) */
export function classifyContainerStatus(statusCode: igClient.IgContainerStatusCode): ContainerPollAction {
  if (statusCode === 'FINISHED' || statusCode === 'PUBLISHED') return 'done';
  if (statusCode === 'ERROR' || statusCode === 'EXPIRED') return 'error';
  return 'continue';
}

/** 画像コンテナ用の次回ポーリング間隔(ms)を経過時間から判定する純粋ロジック */
export function nextImagePollIntervalMs(elapsedMs: number): number {
  return elapsedMs < FIRST_PHASE_DURATION_MS ? FIRST_PHASE_INTERVAL_MS : SECOND_PHASE_INTERVAL_MS;
}

/** 動画(REELS)コンテナ用の次回ポーリング間隔(ms)。固定10秒間隔 */
export function nextVideoPollIntervalMs(): number {
  return VIDEO_POLL_INTERVAL_MS;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function pollUntilTerminal(
  containerId: string,
  accessToken: string,
  totalTimeoutMs: number,
  nextIntervalMs: (elapsedMs: number) => number,
): Promise<void> {
  const start = Date.now();
  for (;;) {
    const { status_code: statusCode } = await igClient.getContainerStatus(containerId, accessToken);
    const action = classifyContainerStatus(statusCode);
    if (action === 'done') return;
    if (action === 'error') throw new IgContainerStatusError(statusCode);

    const elapsed = Date.now() - start;
    if (elapsed >= totalTimeoutMs) throw new IgContainerTimeoutError();
    await sleep(nextIntervalMs(elapsed));
  }
}

/** 画像コンテナ: 5秒間隔(60秒まで)→60秒間隔、最大5分 */
export async function pollContainerStatus(containerId: string, accessToken: string): Promise<void> {
  return pollUntilTerminal(containerId, accessToken, TOTAL_TIMEOUT_MS, nextImagePollIntervalMs);
}

/** 動画(REELS)コンテナ: 10秒間隔固定、最大300秒 */
export async function pollVideoContainerStatus(containerId: string, accessToken: string): Promise<void> {
  return pollUntilTerminal(containerId, accessToken, VIDEO_POLL_TOTAL_TIMEOUT_MS, nextVideoPollIntervalMs);
}
