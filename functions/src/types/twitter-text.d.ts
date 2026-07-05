/**
 * twitter-text (npm) は型定義(.d.ts)を同梱していないための最小アンビエント宣言。
 * 本実装で使用する extractUrls のみを宣言する。
 * 出典: https://docs.x.com/resources/fundamentals/counting-characters
 * (X公式が文字数カウントの正として推奨するライブラリ)
 */
declare module 'twitter-text' {
  export function extractUrls(text: string): string[];
}
