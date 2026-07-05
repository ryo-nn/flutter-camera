import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../../lib/admin';
import type { PublishPostInput } from '../types';

export function postRef(postId: string) {
  return db.doc(`posts/${postId}`);
}

/**
 * 冪等ゲート(backend章「冪等性」節 準拠): 初回実行のみ posts/{postId} を作成する。
 * 既存ドキュメントがある呼び出しはリトライとして扱い、ドキュメントは作り直さない
 * (各ターゲットの実行可否判定は予約トランザクション側=quotaX/quotaIgの責務)。
 *
 * 非選択のターゲットは data章の定義どおり status: 'skipped' で確定する
 * (backend章/quota章が採用する4値(pending/processing/succeeded/failed)+failureKind の
 * 状態機械は「選択されて実行されるターゲット」にのみ適用され、'skipped'は実行対象外の
 * 静的状態としてこの状態機械の外側にある、という解釈で実装する。data章enums.dartの
 * 7値との不整合は design.md 自身が「既存の未解決事項」と明記しているため、本実装は
 * この解釈を明示した上で採用する)。
 */
export async function ensurePostDoc(params: {
  uid: string;
  input: PublishPostInput;
  patternName: string | null;
}): Promise<void> {
  const { uid, input, patternName } = params;
  const ref = postRef(input.postId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return;
    tx.create(ref, {
      userId: uid,
      imagePath: input.imagePath,
      caption: input.caption ?? '',
      // 動画対応追補: 未指定は既存互換のため'image'として扱う
      mediaType: input.mediaType ?? 'image',
      durationSec: input.durationSec ?? null,
      fileSizeBytes: input.fileSizeBytes ?? null,
      patternId: input.patternId ?? null,
      patternName,
      targets: {
        instagram: {
          provider: 'instagram',
          selected: input.targets.instagram,
          status: input.targets.instagram ? 'pending' : 'skipped',
          failureKind: null,
          errorCode: null,
          errorMessage: null,
          publishedId: null,
          postedAt: null,
          fairUseRefunded: false,
        },
        x: {
          provider: 'x',
          selected: input.targets.x,
          status: input.targets.x ? 'pending' : 'skipped',
          failureKind: null,
          errorCode: null,
          errorMessage: null,
          publishedId: null,
          postedAt: null,
          quotaSource: null,
          quotaRefunded: false,
        },
      },
      overallStatus: 'processing',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
