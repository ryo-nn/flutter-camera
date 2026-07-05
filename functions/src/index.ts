import { setGlobalOptions } from 'firebase-functions/v2';

/**
 * backend章「全体方針とランタイム構成」節 準拠。
 * Cloud Functions for Firebase v2 / TypeScript / Node.js 22。
 * 全関数を asia-northeast1(東京)リージョンに固定する。
 */
setGlobalOptions({ region: 'asia-northeast1' });

export { igExchangeToken } from './sns/igExchangeToken';
export { xExchangeToken } from './sns/xExchangeToken';
export { snsDisconnect } from './sns/snsDisconnect';
export { snsPublishPost } from './sns/publishPost/snsPublishPost';
export { snsGetQuota } from './sns/snsGetQuota';
export { igRefreshTokens } from './sns/igRefreshTokens';
export { tempImageCleanup } from './sns/tempImageCleanup';

export { rcWebhook } from './billing/rcWebhook';
export { rcRefreshCustomer } from './billing/rcRefreshCustomer';

export { accountDelete } from './account/accountDelete';
