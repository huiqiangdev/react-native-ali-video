import type { AliVideoViewProps } from './VideoTypes';

export type VideoPlayerProps = Omit<AliVideoViewProps, 'ref'> & {
  /**
   * 视频播放
   */
  title?: string;
  /**
   * 播放完成
   */
  onCompletion?: () => void;
  onBack?: () => void;
  onError?: (code: string, message: string) => void;
  onFullScreen?: (isFull: boolean) => void;
  onProgress?: (progress: number) => void;
  onBufferProgress?: (progress: number) => void;
  onPrepare?: (duration: number) => void;
  isLandscape?: boolean;
};
export type VideoPlayerHandler = {
  play: () => void;
  pause: () => void;
  stop: () => void;
  full: (isFull: boolean) => void;
  seekTo: (position: number) => void;
  destroy: () => void;
};
