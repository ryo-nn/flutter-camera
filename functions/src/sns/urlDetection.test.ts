import { test } from 'node:test';
import assert from 'node:assert/strict';
import { containsUrl, detectCaptionUrls } from './urlDetection';

test('containsUrl: URLを含まない通常の文章はfalse', () => {
  assert.equal(containsUrl('今日の一枚です。よろしくお願いします!'), false);
});

test('containsUrl: httpスキーム付きURLを検出する', () => {
  assert.equal(containsUrl('詳細はこちら http://example.com/page です'), true);
});

test('containsUrl: httpsスキーム付きURLを検出する', () => {
  assert.equal(containsUrl('https://example.co.jp/path?query=1'), true);
});

test('containsUrl: スキームなしのドメイン風文字列も検出する(twitter-text仕様)', () => {
  assert.equal(containsUrl('example.com で公開中'), true);
});

test('detectCaptionUrls: 空文字は空配列', () => {
  assert.deepEqual(detectCaptionUrls(''), []);
});
