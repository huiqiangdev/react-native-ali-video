import React, { createRef, forwardRef, useImperativeHandle } from 'react';
import type { View } from 'react-native';
import type { AliVideoViewHandleType, AliVideoViewProps } from './VideoTypes';
import {
  AliVideoNativeView,
  destroyPlay,
  getViewId,
  pausePlay,
  reloadPlay,
  restartPlay,
  seekTo,
  startPlay,
  stopPlay,
} from './VideoUtils';
import { StyleSheet } from 'react-native';
const refView = createRef<View>();
export const CustomVideoView = (
  { style, ...rest }: AliVideoViewProps,
  ref?: React.Ref<AliVideoViewHandleType>
) => {
  useImperativeHandle(ref, () => ({
    startPlay: () => {
      startPlay(getViewId(refView));
    },
    pausePlay: () => {
      pausePlay(getViewId(refView));
    },
    seekTo: (position) => {
      seekTo(getViewId(refView), position);
    },
    stopPlay: () => {
      stopPlay(getViewId(refView));
    },
    destroyPlay: () => {
      destroyPlay(getViewId(refView));
    },
    reloadPlay: () => {
      reloadPlay(getViewId(refView));
    },
    restartPlay: () => {
      restartPlay(getViewId(refView));
    },
  }));

  return (
    <AliVideoNativeView
      ref={refView}
      {...rest}
      style={StyleSheet.flatten([styles.defaultStyle, style])}
    />
  );
};
export const AliVideoView = forwardRef(CustomVideoView);
const styles = StyleSheet.create({
  defaultStyle: {},
});
