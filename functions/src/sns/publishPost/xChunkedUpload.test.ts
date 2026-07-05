import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  computeChunkRanges,
  classifyXProcessingState,
  hasExceededProcessingTimeout,
  X_VIDEO_PROCESSING_TIMEOUT_MS,
} from './xChunkedUpload';

test('computeChunkRanges: totalBytesが0以下は空配列', () => {
  assert.deepEqual(computeChunkRanges(0), []);
  assert.deepEqual(computeChunkRanges(-1), []);
});

test('computeChunkRanges: ちょうど1チャンク分は1件', () => {
  const ranges = computeChunkRanges(10, 10);
  assert.deepEqual(ranges, [{ segmentIndex: 0, start: 0, end: 9 }]);
});

test('computeChunkRanges: 端数がある場合は最終チャンクが短くなる', () => {
  const ranges = computeChunkRanges(10, 3);
  assert.deepEqual(ranges, [
    { segmentIndex: 0, start: 0, end: 2 },
    { segmentIndex: 1, start: 3, end: 5 },
    { segmentIndex: 2, start: 6, end: 8 },
    { segmentIndex: 3, start: 9, end: 9 },
  ]);
});

test('computeChunkRanges: 5MB固定チャンクで総バイト数をすべて網羅する(重複・欠落なし)', () => {
  const totalBytes = 12 * 1024 * 1024 + 1234; // 5MBチャンクで割り切れない値
  const ranges = computeChunkRanges(totalBytes);
  assert.equal(ranges[0].start, 0);
  assert.equal(ranges[ranges.length - 1].end, totalBytes - 1);
  for (let i = 1; i < ranges.length; i++) {
    assert.equal(ranges[i].start, ranges[i - 1].end + 1);
    assert.equal(ranges[i].segmentIndex, i);
  }
});

test('classifyXProcessingState: succeededはdone', () => {
  assert.equal(classifyXProcessingState('succeeded'), 'done');
});

test('classifyXProcessingState: failedはfailed', () => {
  assert.equal(classifyXProcessingState('failed'), 'failed');
});

test('classifyXProcessingState: pending/in_progressはcontinue', () => {
  assert.equal(classifyXProcessingState('pending'), 'continue');
  assert.equal(classifyXProcessingState('in_progress'), 'continue');
});

test('hasExceededProcessingTimeout: 300秒未満はfalse、以降はtrue', () => {
  assert.equal(hasExceededProcessingTimeout(X_VIDEO_PROCESSING_TIMEOUT_MS - 1), false);
  assert.equal(hasExceededProcessingTimeout(X_VIDEO_PROCESSING_TIMEOUT_MS), true);
});
