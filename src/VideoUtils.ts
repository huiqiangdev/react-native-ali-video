import {
  findNodeHandle,
  Platform,
  requireNativeComponent,
  UIManager,
} from 'react-native';
import type { MutableRefObject } from 'react';
import type { AliVideoViewProps } from './VideoTypes';

const ComponentName = 'AliVideoView';
const LINKING_ERROR =
  `The package 'react-native-ali-video' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

/**
 * 原生的视频播放组件 AliPlayer
 */
export const AliVideoNativeView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<AliVideoViewProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
/**
 * 开始播放
 * @param viewId
 */
export const startPlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.startPlay,
    [viewId]
  );
};
/**
 * 暂停播放
 * @param viewId
 */
export const pausePlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.pausePlay,
    [viewId]
  );
};
/**
 * 停止播放
 * @param viewId
 */
export const stopPlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.stopPlay,
    [viewId]
  );
};
/**
 * 重载播放
 * @param viewId
 */
export const reloadPlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.reloadPlay,
    [viewId]
  );
};
/**
 * 重新播放
 * @param viewId
 */
export const restartPlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.restartPlay,
    [viewId]
  );
};
/**
 * 释放
 * @param viewId
 */
export const destroyPlay = (viewId: number | null) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.destroyPlay,
    [viewId]
  );
};

export const seekTo = (viewId: number | null, position: number) => {
  UIManager.dispatchViewManagerCommand(
    viewId,
    UIManager.getViewManagerConfig(ComponentName).Commands.seekTo,
    [viewId, position]
  );
};
export const getViewId = (ref?: MutableRefObject<any>): number | null => {
  return ref ? findNodeHandle(ref.current) : null;
};
