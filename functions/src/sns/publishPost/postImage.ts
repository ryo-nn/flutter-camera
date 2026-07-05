import { bucket } from '../../lib/admin';

/** users/{uid}/postImages/{imageId}.jpg の恒久オブジェクトをバイナリとして取得する(X画像投稿用) */
export async function downloadPostImage(imagePath: string): Promise<Buffer> {
  const [buffer] = await bucket.file(imagePath).download();
  return buffer;
}

export interface PostImageMetadata {
  size: number;
  contentType?: string;
}

/**
 * Storageオブジェクトの実メタデータ(サイズ・content-type)を取得する(動画対応追補)。
 * クライアント申告値(fileSizeBytes/mediaType)のみを信用せず、Storage上の実体と
 * 突き合わせ検証するために使う(mediaValidation.validateStorageObjectMatchesClaim)。
 * GCS JSON APIの `size` は unsigned long のため文字列で返る場合がある
 * (出典: https://docs.cloud.google.com/storage/docs/json_api/v1/objects)。
 */
export async function getPostImageMetadata(imagePath: string): Promise<PostImageMetadata> {
  const [metadata] = await bucket.file(imagePath).getMetadata();
  return {
    size: Number(metadata.size ?? 0),
    contentType: metadata.contentType,
  };
}
