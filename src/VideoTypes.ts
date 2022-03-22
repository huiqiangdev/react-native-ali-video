import type { NativeSyntheticEvent, View } from 'react-native';
import type React from 'react';

/**
 * 播放器播放完成
 */
export type OnCompletionEvent = (e: NativeSyntheticEvent<{}>) => void;
/**
 * 播放器准备完成
 * duration 秒
 */
export type OnPrepareEvent = (
  e: NativeSyntheticEvent<{ duration: number }>
) => void;
/**
 * 播放器播放失败
 */
export type OnErrorEvent = (
  e: NativeSyntheticEvent<{ code: string; message: string }>
) => void;
/**
 * 播放器加载开始事件
 */
export type OnLoadingBeginEvent = (e: NativeSyntheticEvent<{}>) => void;
/**
 * 播放器加载进度
 */
export type OnLoadingProgressEvent = (
  e: NativeSyntheticEvent<{ percent: number }>
) => void;
/**
 * 播放器进度加载完成
 */
export type OnLoadingEndEvent = (e: NativeSyntheticEvent<{}>) => void;

/**
 * 首帧渲染
 */
export type OnRenderingStartEvent = (e: NativeSyntheticEvent<{}>) => void;
/**
 * 拖动完成事件
 */
export type OnSeekCompleteEvent = (e: NativeSyntheticEvent<{}>) => void;
/**
 * 进度更新事件
 * position 位置
 */
export type onCurrentPositionUpdateEvent = (
  e: NativeSyntheticEvent<{ position: number }>
) => void;
/**
 * 缓存进度更新
 */
export type OnBufferedPositionUpdateEvent = (
  e: NativeSyntheticEvent<{ position: number }>
) => void;
/**
 * 自动播放开始
 */
export type OnAutoPlayStartEvent = (e: NativeSyntheticEvent<{}>) => void;
/**
 * 循环播放开始
 */
export type OnLoopingStartEvent = (e: NativeSyntheticEvent<{}>) => void;

export type AliVideoViewEvent = Partial<{
  onAliCompletion: OnCompletionEvent; // 播放完成事件
  onAliError: OnErrorEvent; // 出错事件
  onAliLoadingBegin: OnLoadingBeginEvent; // 缓冲开始。
  onAliLoadingProgress: OnLoadingProgressEvent; // 缓冲进度
  onAliLoadingEnd: OnLoadingEndEvent; // 缓冲结束
  onAliPrepared: OnPrepareEvent; // 准备成功事件
  onAliRenderingStart: OnRenderingStartEvent; // 首帧渲染显示事件
  onAliSeekComplete: OnSeekCompleteEvent; // 拖动结束
  onAliCurrentPositionUpdate: onCurrentPositionUpdateEvent; // 播放进度
  onAliBufferedPositionUpdate: OnBufferedPositionUpdateEvent; // 缓冲进度
  onAliAutoPlayStart: OnAutoPlayStartEvent; // 自动播放开始
  onAliLoopingStart: OnLoopingStartEvent; // 循环播放开始
}>;
export type AliVideoViewProps = React.ComponentPropsWithRef<typeof View> & {
  /** 视频播放链接 、暂不支持本地*/
  source: string;
  /** 是否自动播放*/
  setAutoPlay?: boolean;
  /** 是否循环播放*/
  setLoop?: boolean;
  /** 是否静音*/
  setMute?: boolean;
  /**
   * 是否使用硬解码
   */
  enableHardwareDecoder?: boolean;
  /**
   * 是否启用原生的控制器
   */
  enableControl?: boolean;
  /**
   * 是否后台播放
   */
  enableBackground?: boolean;
  /**
   * 调节声音
   */
  setVolume?: number;
  /**
   * 调节倍速
   */
  setSpeed?: number;
  /**
   * 请求referer
   */
  setReferer?: string;
  /**
   * 用户头
   */
  setUserAgent?: string;
  /**
   * 渲染镜像模式
   * AVP_MIRRORMODE_NONE 0
   * AVP_MIRRORMODE_HORIZONTAL 1
   * AVP_MIRRORMODE_VERTICAL 2
   */
  setMirrorMode?: number;
  /**
   * 渲染旋转模式
   * AVP_ROTATE_0  0
   * AVP_ROTATE_90 1
   * AVP_ROTATE_180 2
   * AVP_ROTATE_270 3
   */
  setRotateMode?: number;
  /**
   * 渲染显示模式
   * AVP_SCALINGMODE_SCALETOFILL 0
   * 不保持比例平铺
   *
   * AVP_SCALINGMODE_SCALEASPECTFIT 1
   * 保持比例，黑边
   *
   * AVP_SCALINGMODE_SCALEASPECTFILL 2
   * 保持比例填充，需裁剪
   */
  setScaleMode?: number;
} & AliVideoViewEvent;
export type AliVideoViewHandleType = {
  /**
   * 进度跳转
   * @param position
   */
  seekTo: (position: number) => void;
  /**
   * 开始播放
   */
  startPlay: () => void;
  /**
   * 暂停播放
   */
  pausePlay: () => void;
  /**
   * 停止播放
   */
  stopPlay: () => void;
  /**
   * 重载播放
   */
  reloadPlay: () => void;
  /**
   * 重头开始播放
   */
  restartPlay: () => void;
  /**
   * 销毁播放器
   */
  destroyPlay: () => void;
};
