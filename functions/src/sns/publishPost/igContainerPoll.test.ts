import { test } from 'node:test';
import assert from 'node:assert/strict';
import { classifyContainerStatus, nextImagePollIntervalMs, nextVideoPollIntervalMs } from './igContainerPoll';

test('classifyContainerStatus: FINISHEDはdone', () => {
  assert.equal(classifyContainerStatus('FINISHED'), 'done');
});

test('classifyContainerStatus: PUBLISHEDはdone', () => {
  assert.equal(classifyContainerStatus('PUBLISHED'), 'done');
});

test('classifyContainerStatus: ERRORはerror', () => {
  assert.equal(classifyContainerStatus('ERROR'), 'error');
});

test('classifyContainerStatus: EXPIREDはerror', () => {
  assert.equal(classifyContainerStatus('EXPIRED'), 'error');
});

test('classifyContainerStatus: IN_PROGRESSはcontinue', () => {
  assert.equal(classifyContainerStatus('IN_PROGRESS'), 'continue');
});

test('nextImagePollIntervalMs: 60秒未満は5秒間隔', () => {
  assert.equal(nextImagePollIntervalMs(0), 5_000);
  assert.equal(nextImagePollIntervalMs(59_999), 5_000);
});

test('nextImagePollIntervalMs: 60秒以降は60秒間隔', () => {
  assert.equal(nextImagePollIntervalMs(60_000), 60_000);
  assert.equal(nextImagePollIntervalMs(120_000), 60_000);
});

test('nextVideoPollIntervalMs: 常に10秒固定', () => {
  assert.equal(nextVideoPollIntervalMs(), 10_000);
});
