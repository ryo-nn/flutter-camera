import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildAccountDeleteTargets, deviceOwnershipReleaseFields } from './accountDeleteTargets';

test('buildAccountDeleteTargets: users本体ドキュメントパスはusers/{uid}', () => {
  const targets = buildAccountDeleteTargets('uid1');
  assert.equal(targets.userDocPath, 'users/uid1');
});

test('buildAccountDeleteTargets: snsTokensはinstagram/x両方のドキュメントIDを列挙する', () => {
  const targets = buildAccountDeleteTargets('uid1');
  assert.deepEqual(targets.snsTokenDocPaths, ['snsTokens/uid1_instagram', 'snsTokens/uid1_x']);
});

test('buildAccountDeleteTargets: onboardingGrantsはuidをドキュメントIDとする', () => {
  const targets = buildAccountDeleteTargets('uid1');
  assert.equal(targets.onboardingGrantDocPath, 'onboardingGrants/uid1');
});

test('buildAccountDeleteTargets: uidクエリ削除対象はpatterns/posts/postUsageの3コレクション(フィールド名も一致)', () => {
  const targets = buildAccountDeleteTargets('uid1');
  assert.deepEqual(targets.uidQueryTargets, [
    { collection: 'patterns', field: 'ownerUid' },
    { collection: 'posts', field: 'userId' },
    { collection: 'postUsage', field: 'uid' },
  ]);
});

test('buildAccountDeleteTargets: 保持判断済みのrcEvents/creditGrants/devicesはクエリ削除対象に含めない', () => {
  const targets = buildAccountDeleteTargets('uid1');
  const collections = targets.uidQueryTargets.map((t) => t.collection);
  for (const kept of ['rcEvents', 'creditGrants', 'devices']) {
    assert.equal(collections.includes(kept), false, `collection=${kept}`);
  }
});

test('buildAccountDeleteTargets: Storage削除プレフィックスはpostImages配下とigTemp配下の両方かつ末尾スラッシュ付き', () => {
  const targets = buildAccountDeleteTargets('uid1');
  assert.deepEqual(targets.storagePrefixes, ['users/uid1/', 'igTemp/uid1/']);
});

test('buildAccountDeleteTargets: uidが異なれば全パスが衝突しない(他ユーザーへの誤爆防止)', () => {
  const a = buildAccountDeleteTargets('uidA');
  const b = buildAccountDeleteTargets('uidB');
  assert.notEqual(a.userDocPath, b.userDocPath);
  assert.notDeepEqual(a.snsTokenDocPaths, b.snsTokenDocPaths);
  assert.notEqual(a.onboardingGrantDocPath, b.onboardingGrantDocPath);
  assert.notDeepEqual(a.storagePrefixes, b.storagePrefixes);
});

test('deviceOwnershipReleaseFields: freeOwnerUidのみをnullにし、他フィールド(乱用対策情報)には触れない', () => {
  const fields = deviceOwnershipReleaseFields();
  assert.deepEqual(Object.keys(fields), ['freeOwnerUid']);
  assert.equal(fields.freeOwnerUid, null);
});
