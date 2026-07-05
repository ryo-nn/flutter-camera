/**
 * X API v2 (OAuth 2.0 Authorization Code with PKCE) クライアント。
 * 出典: design.md backend章「X連携設計」節、公式:
 * https://docs.x.com/resources/fundamentals/authentication/oauth-2-0/authorization-code
 * https://docs.x.com/x-api/posts/create-post
 * https://docs.x.com/x-api/media/upload-media
 */

const X_API_BASE = 'https://api.x.com';

function basicAuthHeader(clientId: string, clientSecret: string): string {
  return 'Basic ' + Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
}

async function xFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  const json = (await res.json().catch(() => ({}))) as T;
  if (!res.ok) {
    const err = new Error(`X API error (${res.status}): ${JSON.stringify(json)}`) as Error & {
      status: number;
      body: unknown;
    };
    err.status = res.status;
    err.body = json;
    throw err;
  }
  return json;
}

export interface XTokenResponse {
  access_token: string;
  refresh_token?: string;
  expires_in: number;
  scope: string;
  token_type: string;
}

export async function exchangeToken(params: {
  code: string;
  codeVerifier: string;
  redirectUri: string;
  clientId: string;
  clientSecret: string;
}): Promise<XTokenResponse> {
  const body = new URLSearchParams({
    code: params.code,
    grant_type: 'authorization_code',
    redirect_uri: params.redirectUri,
    code_verifier: params.codeVerifier,
  });
  return xFetch<XTokenResponse>(`${X_API_BASE}/2/oauth2/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: basicAuthHeader(params.clientId, params.clientSecret),
    },
    body,
  });
}

export async function refreshAccessToken(params: {
  refreshToken: string;
  clientId: string;
  clientSecret: string;
}): Promise<XTokenResponse> {
  const body = new URLSearchParams({
    grant_type: 'refresh_token',
    refresh_token: params.refreshToken,
    client_id: params.clientId,
  });
  return xFetch<XTokenResponse>(`${X_API_BASE}/2/oauth2/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: basicAuthHeader(params.clientId, params.clientSecret),
    },
    body,
  });
}

export async function getMe(accessToken: string): Promise<{ data: { id: string; username: string; name: string } }> {
  return xFetch(`${X_API_BASE}/2/users/me`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
}

export async function revokeToken(params: {
  token: string;
  clientId: string;
  clientSecret: string;
}): Promise<{ revoked: boolean }> {
  const body = new URLSearchParams({ token: params.token, client_id: params.clientId });
  return xFetch(`${X_API_BASE}/2/oauth2/revoke`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: basicAuthHeader(params.clientId, params.clientSecret),
    },
    body,
  });
}

export async function uploadMedia(
  accessToken: string,
  imageBuffer: Buffer,
): Promise<{ data: { id: string; media_key?: string } }> {
  const form = new FormData();
  form.append('media', new Blob([new Uint8Array(imageBuffer)], { type: 'image/jpeg' }), 'image.jpg');
  form.append('media_category', 'tweet_image');
  form.append('media_type', 'image/jpeg');
  return xFetch(`${X_API_BASE}/2/media/upload`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
}

/**
 * 動画投稿対応追補: チャンクアップロード(INIT/APPEND/FINALIZE/STATUS)クライアント。
 * 出典: https://docs.x.com/x-api/media/quickstart/media-upload-chunked
 * 4コマンドすべて同一エンドポイント `POST /2/media/upload`(STATUSのみGET)。
 * INIT/APPEND/FINALIZEはmultipart/form-data(`command`フィールドで種別指定)。
 */

export interface XMediaProcessingInfo {
  state: 'pending' | 'in_progress' | 'succeeded' | 'failed';
  check_after_secs?: number;
  progress_percent?: number;
  error?: { code?: number; name?: string; message?: string };
}

export interface XMediaUploadResponse {
  data: {
    id: string;
    media_key?: string;
    expires_after_secs?: number;
    processing_info?: XMediaProcessingInfo;
  };
}

export async function initVideoUpload(
  accessToken: string,
  totalBytes: number,
  mediaType: string,
): Promise<XMediaUploadResponse> {
  const form = new FormData();
  form.append('command', 'INIT');
  form.append('media_type', mediaType);
  form.append('media_category', 'tweet_video');
  form.append('total_bytes', String(totalBytes));
  return xFetch(`${X_API_BASE}/2/media/upload`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
}

export async function appendVideoChunk(
  accessToken: string,
  params: { mediaId: string; segmentIndex: number; chunk: Buffer },
): Promise<void> {
  const form = new FormData();
  form.append('command', 'APPEND');
  form.append('media_id', params.mediaId);
  form.append('segment_index', String(params.segmentIndex));
  form.append(
    'media',
    new Blob([new Uint8Array(params.chunk)], { type: 'video/mp4' }),
    `chunk-${params.segmentIndex}.mp4`,
  );
  await xFetch<Record<string, never>>(`${X_API_BASE}/2/media/upload`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
}

export async function finalizeVideoUpload(accessToken: string, mediaId: string): Promise<XMediaUploadResponse> {
  const form = new FormData();
  form.append('command', 'FINALIZE');
  form.append('media_id', mediaId);
  return xFetch(`${X_API_BASE}/2/media/upload`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
}

export async function getVideoUploadStatus(accessToken: string, mediaId: string): Promise<XMediaUploadResponse> {
  const url = new URL(`${X_API_BASE}/2/media/upload`);
  url.searchParams.set('command', 'STATUS');
  url.searchParams.set('media_id', mediaId);
  return xFetch(url.toString(), {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
}

export async function createTweet(
  accessToken: string,
  text: string,
  mediaId: string,
): Promise<{ data: { id: string; text: string } }> {
  return xFetch(`${X_API_BASE}/2/tweets`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ text, media: { media_ids: [mediaId] } }),
  });
}
