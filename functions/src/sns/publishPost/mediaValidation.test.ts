import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  IG_VIDEO_CONTENT_TYPES,
  IG_VIDEO_LIMITS,
  X_VIDEO_CONTENT_TYPES,
  X_VIDEO_LIMITS,
  validateVideoClaim,
  validateStorageObjectMatchesClaim,
} from './mediaValidation';

test('validateVideoClaim: durationSec未指定はエラー', () => {
  const err = validateVideoClaim({ fileSizeBytes: 1024 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /durationSec/);
});

test('validateVideoClaim: durationSecが下限未満はエラー(IG)', () => {
  const err = validateVideoClaim({ durationSec: 2.9, fileSizeBytes: 1024 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /durationSec/);
});

test('validateVideoClaim: durationSecが上限超過はエラー(IG)', () => {
  const err = validateVideoClaim({ durationSec: 900.1, fileSizeBytes: 1024 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /durationSec/);
});

test('validateVideoClaim: durationSecが境界値(下限・上限ちょうど)は許可(IG: 3〜900)', () => {
  assert.equal(validateVideoClaim({ durationSec: 3, fileSizeBytes: 1024 }, IG_VIDEO_LIMITS), null);
  assert.equal(validateVideoClaim({ durationSec: 900, fileSizeBytes: 1024 }, IG_VIDEO_LIMITS), null);
});

test('validateVideoClaim: durationSecが境界値(下限・上限ちょうど)は許可(X: 0.5〜140)', () => {
  assert.equal(validateVideoClaim({ durationSec: 0.5, fileSizeBytes: 1024 }, X_VIDEO_LIMITS), null);
  assert.equal(validateVideoClaim({ durationSec: 140, fileSizeBytes: 1024 }, X_VIDEO_LIMITS), null);
});

test('validateVideoClaim: durationSecがX下限未満はエラー', () => {
  const err = validateVideoClaim({ durationSec: 0.4, fileSizeBytes: 1024 }, X_VIDEO_LIMITS);
  assert.match(err ?? '', /durationSec/);
});

test('validateVideoClaim: durationSecがX上限超過はエラー', () => {
  const err = validateVideoClaim({ durationSec: 140.1, fileSizeBytes: 1024 }, X_VIDEO_LIMITS);
  assert.match(err ?? '', /durationSec/);
});

test('validateVideoClaim: fileSizeBytes未指定はエラー', () => {
  const err = validateVideoClaim({ durationSec: 10 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateVideoClaim: fileSizeBytesが0以下はエラー', () => {
  const err = validateVideoClaim({ durationSec: 10, fileSizeBytes: 0 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateVideoClaim: fileSizeBytesがIG上限(300MB)ちょうどは許可、超過はエラー', () => {
  const limit = IG_VIDEO_LIMITS.maxFileSizeBytes;
  assert.equal(validateVideoClaim({ durationSec: 10, fileSizeBytes: limit }, IG_VIDEO_LIMITS), null);
  const err = validateVideoClaim({ durationSec: 10, fileSizeBytes: limit + 1 }, IG_VIDEO_LIMITS);
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateVideoClaim: fileSizeBytesがX上限(512MB)ちょうどは許可、超過はエラー', () => {
  const limit = X_VIDEO_LIMITS.maxFileSizeBytes;
  assert.equal(validateVideoClaim({ durationSec: 10, fileSizeBytes: limit }, X_VIDEO_LIMITS), null);
  const err = validateVideoClaim({ durationSec: 10, fileSizeBytes: limit + 1 }, X_VIDEO_LIMITS);
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateVideoClaim: 正常値の組み合わせはnull', () => {
  assert.equal(validateVideoClaim({ durationSec: 30, fileSizeBytes: 10 * 1024 * 1024 }, IG_VIDEO_LIMITS), null);
  assert.equal(validateVideoClaim({ durationSec: 30, fileSizeBytes: 10 * 1024 * 1024 }, X_VIDEO_LIMITS), null);
});

test('validateStorageObjectMatchesClaim: 動画でcontentTypeが一致すればnull', () => {
  const err = validateStorageObjectMatchesClaim('video', 100, { size: 100, contentType: 'video/mp4' });
  assert.equal(err, null);
});

test('validateStorageObjectMatchesClaim: 動画でcontentTypeが不一致はエラー', () => {
  const err = validateStorageObjectMatchesClaim('video', 100, { size: 100, contentType: 'image/jpeg' });
  assert.match(err ?? '', /content-type/);
});

test('validateStorageObjectMatchesClaim: 動画でサイズ不一致はエラー', () => {
  const err = validateStorageObjectMatchesClaim('video', 100, { size: 200, contentType: 'video/mp4' });
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateStorageObjectMatchesClaim: 動画でclaimedFileSizeBytes未指定はエラー', () => {
  const err = validateStorageObjectMatchesClaim('video', undefined, { size: 200, contentType: 'video/mp4' });
  assert.match(err ?? '', /fileSizeBytes/);
});

test('validateStorageObjectMatchesClaim: IGはvideo/quicktime(MOV)も許可する', () => {
  const err = validateStorageObjectMatchesClaim(
    'video',
    100,
    { size: 100, contentType: 'video/quicktime' },
    IG_VIDEO_CONTENT_TYPES,
  );
  assert.equal(err, null);
});

test('validateStorageObjectMatchesClaim: IGはvideo/mp4も引き続き許可する', () => {
  const err = validateStorageObjectMatchesClaim(
    'video',
    100,
    { size: 100, contentType: 'video/mp4' },
    IG_VIDEO_CONTENT_TYPES,
  );
  assert.equal(err, null);
});

test('validateStorageObjectMatchesClaim: Xはvideo/quicktime(MOV)を許可しない', () => {
  const err = validateStorageObjectMatchesClaim(
    'video',
    100,
    { size: 100, contentType: 'video/quicktime' },
    X_VIDEO_CONTENT_TYPES,
  );
  assert.match(err ?? '', /content-type/);
});

test('validateStorageObjectMatchesClaim: Xはvideo/mp4のみ許可する', () => {
  const err = validateStorageObjectMatchesClaim(
    'video',
    100,
    { size: 100, contentType: 'video/mp4' },
    X_VIDEO_CONTENT_TYPES,
  );
  assert.equal(err, null);
});

test('validateStorageObjectMatchesClaim: 画像でcontentTypeが一致すればnull(サイズは突合しない)', () => {
  const err = validateStorageObjectMatchesClaim('image', undefined, { size: 12345, contentType: 'image/jpeg' });
  assert.equal(err, null);
});

test('validateStorageObjectMatchesClaim: 画像でcontentTypeが不一致はエラー', () => {
  const err = validateStorageObjectMatchesClaim('image', undefined, { size: 12345, contentType: 'video/mp4' });
  assert.match(err ?? '', /content-type/);
});
