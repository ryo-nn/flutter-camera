import type { MediaType } from '../types';

export interface PublishContext {
  uid: string;
  postId: string;
  imagePath: string;
  caption: string;
  force: boolean;
  deviceId?: string;
  platform?: 'ios' | 'android';
  phoneNumberClaim?: string;
  /** 動画対応追補。snsPublishPost側で未指定時は'image'に解決済み */
  mediaType: MediaType;
  /** mediaType: 'video' 時のみ意味を持つ(秒) */
  durationSec?: number;
  /** mediaType: 'video' 時のみ意味を持つ(バイト) */
  fileSizeBytes?: number;
}
