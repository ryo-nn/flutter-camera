/**
 * Instagram API with Instagram Login(Business Login) クライアント。
 * 出典: design.md backend章「Instagram連携設計」節、公式:
 * https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login/get-started
 * https://developers.facebook.com/docs/instagram-platform/content-publishing
 */

const IG_GRAPH_BASE = 'https://graph.instagram.com';
const IG_API_VERSION = 'v25.0';

interface IgErrorBody {
  error?: { message?: string; type?: string; code?: number; error_subcode?: number };
}

async function igFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  const json = (await res.json().catch(() => ({}))) as T & IgErrorBody;
  if (!res.ok) {
    const err = new Error(`Instagram API error (${res.status}): ${JSON.stringify(json)}`) as Error & {
      status: number;
      body: unknown;
    };
    err.status = res.status;
    err.body = json;
    throw err;
  }
  return json;
}

export interface IgShortLivedToken {
  access_token: string;
  user_id: string;
  permissions?: string[];
}

export async function exchangeShortLivedToken(params: {
  code: string;
  redirectUri: string;
  appId: string;
  appSecret: string;
}): Promise<IgShortLivedToken> {
  const body = new URLSearchParams({
    client_id: params.appId,
    client_secret: params.appSecret,
    grant_type: 'authorization_code',
    redirect_uri: params.redirectUri,
    code: params.code,
  });
  return igFetch<IgShortLivedToken>('https://api.instagram.com/oauth/access_token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
}

export interface IgLongLivedToken {
  access_token: string;
  token_type?: string;
  expires_in: number;
}

export async function exchangeLongLivedToken(
  shortLivedToken: string,
  appSecret: string,
): Promise<IgLongLivedToken> {
  const url = new URL(`${IG_GRAPH_BASE}/access_token`);
  url.searchParams.set('grant_type', 'ig_exchange_token');
  url.searchParams.set('client_secret', appSecret);
  url.searchParams.set('access_token', shortLivedToken);
  return igFetch<IgLongLivedToken>(url.toString());
}

export async function refreshLongLivedToken(longLivedToken: string): Promise<IgLongLivedToken> {
  const url = new URL(`${IG_GRAPH_BASE}/refresh_access_token`);
  url.searchParams.set('grant_type', 'ig_refresh_token');
  url.searchParams.set('access_token', longLivedToken);
  return igFetch<IgLongLivedToken>(url.toString());
}

export interface IgProfile {
  user_id: string;
  username: string;
  account_type: string;
}

export async function getProfile(accessToken: string): Promise<IgProfile> {
  const url = new URL(`${IG_GRAPH_BASE}/${IG_API_VERSION}/me`);
  url.searchParams.set('fields', 'user_id,username,account_type');
  url.searchParams.set('access_token', accessToken);
  return igFetch<IgProfile>(url.toString());
}

export interface IgPublishingLimit {
  data: Array<{ quota_usage: number; config: { quota_total: number; quota_duration: number } }>;
}

export async function getContentPublishingLimit(
  igUserId: string,
  accessToken: string,
): Promise<IgPublishingLimit> {
  const url = new URL(`${IG_GRAPH_BASE}/${IG_API_VERSION}/${igUserId}/content_publishing_limit`);
  url.searchParams.set('fields', 'quota_usage,config');
  url.searchParams.set('access_token', accessToken);
  return igFetch<IgPublishingLimit>(url.toString());
}

export async function createMediaContainer(
  igUserId: string,
  accessToken: string,
  imageUrl: string,
  caption: string,
): Promise<{ id: string }> {
  const body = new URLSearchParams({ image_url: imageUrl, caption, access_token: accessToken });
  return igFetch<{ id: string }>(`${IG_GRAPH_BASE}/${IG_API_VERSION}/${igUserId}/media`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
}

/**
 * 動画(Reels)投稿用コンテナ作成。media_type=REELS + video_url を指定する。
 * 出典: https://developers.facebook.com/docs/instagram-platform/content-publishing
 */
export async function createVideoMediaContainer(
  igUserId: string,
  accessToken: string,
  videoUrl: string,
  caption: string,
): Promise<{ id: string }> {
  const body = new URLSearchParams({
    media_type: 'REELS',
    video_url: videoUrl,
    caption,
    access_token: accessToken,
  });
  return igFetch<{ id: string }>(`${IG_GRAPH_BASE}/${IG_API_VERSION}/${igUserId}/media`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
}

export type IgContainerStatusCode = 'FINISHED' | 'IN_PROGRESS' | 'ERROR' | 'EXPIRED' | 'PUBLISHED';

export async function getContainerStatus(
  containerId: string,
  accessToken: string,
): Promise<{ status_code: IgContainerStatusCode }> {
  const url = new URL(`${IG_GRAPH_BASE}/${IG_API_VERSION}/${containerId}`);
  url.searchParams.set('fields', 'status_code');
  url.searchParams.set('access_token', accessToken);
  return igFetch<{ status_code: IgContainerStatusCode }>(url.toString());
}

export async function publishMedia(
  igUserId: string,
  accessToken: string,
  creationId: string,
): Promise<{ id: string }> {
  const body = new URLSearchParams({ creation_id: creationId, access_token: accessToken });
  return igFetch<{ id: string }>(`${IG_GRAPH_BASE}/${IG_API_VERSION}/${igUserId}/media_publish`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
}
