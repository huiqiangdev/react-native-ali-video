import {
  NativeSyntheticEvent,
  StatusBar,
  StyleSheet,
  View,
  ViewStyle,
} from 'react-native';
import React, {
  forwardRef,
  useEffect,
  useImperativeHandle,
  useRef,
  useState,
} from 'react';
import { AliVideoView } from './AliVideoView';
import type { VideoPlayerHandler, VideoPlayerProps } from './PlayTypes';
import type { AliVideoViewHandleType } from './VideoTypes';
import { useBackHandler, useDimensions } from '@react-native-community/hooks';
import ControllerView from './ControllerView';

const VideoPlayer = forwardRef(
  (
    {
      source,
      onCompletion,
      onBufferProgress,
      onPrepare,
      onProgress,
      onFullScreen,
      onError,
      style,
      title,
      onBack,
      isLandscape,
      onAliBufferedPositionUpdate,
      onAliCurrentPositionUpdate,
      onAliLoadingBegin,
      onAliCompletion,
      onAliLoadingEnd,
      onAliError,
      onAliPrepared,
      onAliRenderingStart,
      isHiddenBack,
      isHiddenFullBack,
      ...rest
    }: VideoPlayerProps,
    ref: React.Ref<VideoPlayerHandler>
  ) => {
    const videoRef = useRef<AliVideoViewHandleType>(null);
    const [isFull, setIsFull] = useState(false);
    const [isStopPlay, setIsStopPlay] = useState(false);
    const [isPlaying, setIsPlaying] = useState(false);
    const [currentTime, setCurrentTime] = useState(0);
    const [duration, setDuration] = useState(0);
    const [loading, setLoading] = useState(true);
    const [buffer, setBuffer] = useState(0);
    const [complete, setComplete] = useState(false); // 是否加载完成
    const [playSource, setPlaySource] = useState(source);
    const [innerHiddenBack, setInnerHiddenBack] = useState(isHiddenBack);
    const [innerHiddenFullBack, setInnerHiddenFullBack] =
      useState(isHiddenFullBack);
    const { screen, window } = useDimensions();
    useEffect(() => {
      setInnerHiddenBack(isHiddenBack);
    }, [isHiddenBack]);
    useEffect(() => {
      setInnerHiddenFullBack(isHiddenFullBack);
    }, [isHiddenFullBack]);
    useImperativeHandle(ref, () => ({
      play: () => {
        handlePlay();
      },
      pause: () => {
        handlePause();
      },
      stop: () => {
        handleStop();
      },
      full: (f: boolean) => {
        if (f) {
          handleFullScreenIn();
        } else {
          handleFullScreenOut();
        }
      },
      seekTo: (position: number) => {
        videoRef.current?.seekTo(position);
      },
      destroy: () => {
        videoRef.current?.destroyPlay();
      },
    }));
    useBackHandler(() => {
      if (isFull) {
        handleFullScreenOut();
        return true;
      }
      return false;
    });
    const handlePlay = () => {
      if (complete) {
        videoRef.current?.restartPlay();
        setComplete(false);
      } else if (isStopPlay) {
        videoRef.current?.reloadPlay();
      } else {
        videoRef.current?.startPlay();
      }
      setIsPlaying(true);
    };
    const handlePause = () => {
      videoRef.current?.pausePlay();
      setIsPlaying(false);
    };
    const handleStop = () => {
      videoRef.current?.stopPlay();
      setIsStopPlay(true);
      setIsPlaying(false);
    };
    const handleFullScreenIn = () => {
      onFullScreen?.(true);
      setIsFull(true);
    };
    const handleFullScreenOut = () => {
      onFullScreen?.(false);
      setIsFull(false);
    };
    useEffect(() => {
      setPlaySource(source);
    }, [source]);
    const _onAliPrepared = (e: NativeSyntheticEvent<{ duration: number }>) => {
      setDuration(e.nativeEvent.duration);
      setCurrentTime(0);
      setBuffer(0);
      onPrepare?.(e.nativeEvent.duration);
      onAliPrepared?.(e);
    };
    const _onAliLoadingBegin = (e: NativeSyntheticEvent<{}>) => {
      setLoading(true);
      onAliLoadingBegin?.(e);
    };
    const _onAliLoadingEnd = (e: NativeSyntheticEvent<{}>) => {
      setLoading(false);
      onAliLoadingEnd?.(e);
    };
    const _onAliRenderingStart = (e: NativeSyntheticEvent<{}>) => {
      setLoading(false);
      setIsPlaying(true);
      onAliRenderingStart?.(e);
    };
    const _onAliCurrentPositionUpdate = (
      e: NativeSyntheticEvent<{ position: number }>
    ) => {
      setCurrentTime(e.nativeEvent.position);
      onProgress?.(e.nativeEvent.position);
      onAliCurrentPositionUpdate?.(e);
    };
    const _onAliBufferedPositionUpdate = (
      e: NativeSyntheticEvent<{ position: number }>
    ) => {
      setBuffer(e.nativeEvent.position);
      onBufferProgress?.(e.nativeEvent.position);
      onAliBufferedPositionUpdate?.(e);
    };
    const _onAliCompletion = (e: NativeSyntheticEvent<{}>) => {
      setIsPlaying(false);
      setComplete(true);
      onCompletion?.();
      onAliCompletion?.(e);
    };
    const _onAliError = (
      e: NativeSyntheticEvent<{ code: string; message: string }>
    ) => {
      onError?.(e.nativeEvent.code, e.nativeEvent.message);
      onAliError?.(e);
    };
    const onSliderValueChange = (value: number) => {
      if (complete) {
        videoRef.current?.seekTo(value);
        videoRef.current?.startPlay();
        setIsPlaying(true);
      } else {
        videoRef.current?.seekTo(value);
        setIsPlaying(true);
      }
    };
    const onPressedStart = () => {
      if (isPlaying) {
        handlePause();
      } else {
        handlePlay();
      }
    };
    const onFull = () => {
      if (isFull) {
        handleFullScreenOut();
      } else {
        handleFullScreenIn();
      }
    };
    const isOrientationLandscape = isLandscape;
    const fullscreenStyle = StyleSheet.flatten<ViewStyle>([
      {
        position: 'absolute',
        top: 0,
        right: 0,
        width: isOrientationLandscape
          ? Math.max(screen.width, screen.height)
          : Math.min(screen.width, screen.height),
        height: isOrientationLandscape
          ? Math.min(screen.width, screen.height)
          : Math.max(screen.width, screen.height),
        zIndex: 999,
      },
    ]);
    const fullWindowStyle = StyleSheet.flatten<ViewStyle>([
      {
        position: 'absolute',
        top: 0,
        left: 0,
        width: isOrientationLandscape
          ? Math.max(window.width, window.height)
          : Math.min(window.width, window.height),
        height: isOrientationLandscape
          ? Math.min(window.width, window.height)
          : Math.max(window.width, window.height),
      },
    ]);
    return (
      <View style={[styles.base, isFull ? fullscreenStyle : style]}>
        <AliVideoView
          style={isFull ? fullWindowStyle : StyleSheet.absoluteFill}
          source={playSource}
          onAliBufferedPositionUpdate={_onAliBufferedPositionUpdate}
          onAliLoadingBegin={_onAliLoadingBegin}
          onAliLoadingEnd={_onAliLoadingEnd}
          onAliPrepared={_onAliPrepared}
          onAliRenderingStart={_onAliRenderingStart}
          onAliCurrentPositionUpdate={_onAliCurrentPositionUpdate}
          onAliCompletion={_onAliCompletion}
          onAliError={_onAliError}
          {...rest}
          ref={videoRef}
        />
        <StatusBar hidden={isFull} />
        <ControllerView
          title={title}
          onPause={handlePause}
          onPressedStart={onPressedStart}
          onSliderValueChange={onSliderValueChange}
          current={currentTime}
          isFull={isFull}
          onFull={onFull}
          isHiddenBack={innerHiddenBack}
          isHiddenFullBack={innerHiddenFullBack}
          buffer={buffer}
          isError={false}
          isLoading={loading}
          isStart={isPlaying}
          total={duration}
          onBack={onBack}
        />
      </View>
    );
  }
);
const styles = StyleSheet.create({
  base: {
    overflow: 'hidden',
    backgroundColor: '#000000',
  },
});

export default VideoPlayer;
