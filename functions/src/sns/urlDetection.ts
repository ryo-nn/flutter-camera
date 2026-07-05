import { extractUrls } from 'twitter-text';

/**
 * quota章「X投稿本文のURL検出・ブロック」節 準拠。
 * twitter-text の extractUrls はスキーム付きURLと、TLDに合致する
 * スキームなしドメイン風文字列の両方を検出する(X本体のt.co短縮判定と同じ実装)。
 * 判定基準はクライアント・サーバー共通だが、サーバー側(本関数)が最終判定=唯一の正。
 */
export function detectCaptionUrls(caption: string): string[] {
  return extractUrls(caption ?? '');
}

export function containsUrl(caption: string): boolean {
  return detectCaptionUrls(caption).length > 0;
}
