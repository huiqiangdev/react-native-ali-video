import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  LayoutChangeEvent,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import type { ControllerViewProps } from './ControllerTypes';
import Slider from '@react-native-community/slider';
import {
  Gesture,
  GestureDetector,
  GestureHandlerRootView,
} from 'react-native-gesture-handler';

function formatTime(second: number) {
  let i = 0,
    s = second;
  if (s > 60) {
    i = Math.round(s / 60);
    s = s % 60;
  }
  // 补零
  const zero = function (v: number) {
    return v >> 0 < 10 ? '0' + v : v;
  };
  return [zero(i), zero(s)].join(':');
}
const ControllerView = ({
  total,
  current,
  isFull,
  isStart,
  onPressedStart,
  isLoading,
  onFull,
  onSliderValueChange,
  onBack,
  title,
}: ControllerViewProps) => {
  const [hide, setHide] = useState(false);
  const [width, setWidth] = useState(0);
  const [showSliderTips, setShowSliderTips] = useState(false);
  const [sliderValue, setSliderValue] = useState(current);
  const [autoHide, setAutoHide] = useState(true); /// 自动隐藏
  const onValueChange = (value: number) => {
    setSliderValue(Math.round(value));
    onSliderValueChange?.(value);
  };
  const timeOutRef = useRef<any>();
  useEffect(() => {
    if (!hide && autoHide) {
      if (timeOutRef.current) {
        clearTimeout(timeOutRef.current);
        timeOutRef.current = null;
      }
      timeOutRef.current = setTimeout(() => {
        setHide(true);
      }, 4000);
    }
  }, [hide, autoHide]);
  useEffect(() => {
    if (!isLoading) {
      setHide(false);
    }
  }, [isLoading]);
  useEffect(() => {
    setSliderValue(current);
  }, [current, setSliderValue]);

  const onSlidingStart = () => {
    setAutoHide(false);
    setHide(false);
    setShowSliderTips(true);
  };
  const onSlidingComplete = (value: number) => {
    setAutoHide(true);
    setSliderValue(Math.round(value));
    /// 结束拖动之后慢慢小时
    setTimeout(() => {
      setShowSliderTips(false);
    }, 500);
  };
  const singleTap = Gesture.Tap()
    .runOnJS(true)
    .maxDuration(250)
    .onStart(() => {
      setHide(false);
    });
  const doubleTap = Gesture.Tap()
    .runOnJS(true)
    .maxDuration(250)
    .numberOfTaps(2)
    .onStart(() => {
      setHide(false);
      onPressedStart?.();
    });
  const panGes = Gesture.Pan()
    .runOnJS(true)
    .onStart(() => {
      setHide(false);
      setAutoHide(false);
      setShowSliderTips(true);
    })
    .onUpdate((e) => {
      if (Math.abs(e.translationX) < 15) return;
      setHide(false);
      if (width === 0) return;
      let progress = e.translationX / width;
      if (progress > 1) {
        progress = 1;
      }
      if (progress < -1) {
        progress = -1;
      }
      const value = Math.round(total * progress);
      let targetValue = current + value;
      if (targetValue < 0) {
        targetValue = 0;
      }
      if (targetValue > total) {
        targetValue = total;
      }
      setSliderValue(targetValue);
    })
    .onEnd((e) => {
      setAutoHide(true);
      if (Math.abs(e.translationX) < 15) return;
      setTimeout(() => {
        setShowSliderTips(false);
      }, 500);
      onSliderValueChange?.(sliderValue);
    });
  const onLayout = (e: LayoutChangeEvent) => {
    setWidth(e.nativeEvent.layout.width);
  };
  const renderContainer = () => {
    if (isLoading) {
      return (
        <View style={styles.loading}>
          <ActivityIndicator color={'#FFFFFF'} animating />
          <Text style={styles.loadingText}>正在加载中...</Text>
        </View>
      );
    }
    if (hide) {
      return (
        <>
          {!isFull && (
            <View style={styles.top}>
              <TouchableOpacity onPress={onBack}>
                <Image
                  style={styles.topLeftIcon}
                  source={require('./assets/chevron-down.png')}
                />
              </TouchableOpacity>
            </View>
          )}
        </>
      );
    }
    return (
      <>
        {showSliderTips && (
          <View style={styles.sliderTips}>
            <Text style={styles.time}>{`${formatTime(sliderValue)}/${formatTime(
              total
            )}`}</Text>
          </View>
        )}
        {isFull ? (
          <View style={styles.top}>
            <TouchableOpacity onPress={onFull}>
              <Image
                style={styles.topLeftIcon}
                source={require('./assets/chevron-left.png')}
              />
              <Text>{title ?? ''}</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={styles.top}>
            <TouchableOpacity onPress={onBack}>
              <Image
                style={styles.topLeftIcon}
                source={require('./assets/chevron-down.png')}
              />
            </TouchableOpacity>
          </View>
        )}
        <View style={styles.bottom}>
          <TouchableOpacity onPress={onPressedStart}>
            <Image
              style={styles.bottomLeftIcon}
              source={
                isStart
                  ? require('./assets/pause.png')
                  : require('./assets/play.png')
              }
            />
          </TouchableOpacity>
          <Text style={styles.time}>{formatTime(current)}</Text>
          <Slider
            minimumTrackTintColor={'#0273FF'}
            maximumTrackTintColor={'rgba(255,255,255,0.8)'}
            style={styles.slider}
            thumbTintColor={'#0273FF'}
            // thumbImage={require('./assets/al_play_thumb_image.png')}
            onSlidingStart={onSlidingStart}
            onSlidingComplete={onSlidingComplete}
            minimumValue={0}
            onValueChange={onValueChange}
            value={current}
            maximumValue={total}
          />
          <Text style={styles.time}>{formatTime(total)}</Text>
          {!isFull && (
            <TouchableOpacity onPress={onFull}>
              <Image
                style={styles.bottomRightIcon}
                source={
                  isFull
                    ? require('./assets/exit-fullscreen.png')
                    : require('./assets/fullscreen.png')
                }
              />
            </TouchableOpacity>
          )}
        </View>
      </>
    );
  };
  return (
    <GestureHandlerRootView style={styles.root} onLayout={onLayout}>
      <GestureDetector
        gesture={Gesture.Exclusive(doubleTap, singleTap, panGes)}
      >
        <View collapsable={false} style={styles.container}>
          {renderContainer()}
        </View>
      </GestureDetector>
    </GestureHandlerRootView>
  );
};
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  root: {
    flex: 1,
  },
  time: {
    color: '#FFFFFF',
    fontSize: 14,
  },
  top: {
    position: 'absolute',
    left: 10,
    top: 10,
    right: 10,
    flexDirection: 'row',
  },
  topLeftIcon: {
    width: 36,
    height: 36,
  },
  bottom: {
    position: 'absolute',
    right: 10,
    bottom: 0,
    left: 10,
    flexDirection: 'row',
    alignItems: 'center',
  },
  slider: {
    flex: 1,
  },
  sliderTips: {
    width: 90,
    height: 28,
    borderRadius: 4,
    backgroundColor: 'rgba(100,100,100,0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  loading: {
    alignItems: 'center',
    flexDirection: 'row',
  },
  loadingText: {
    color: '#FFFFFF',
    fontSize: 14,
    marginLeft: 8,
  },
  bottomLeftIcon: {
    width: 30,
    height: 30,
    marginRight: 8,
  },
  bottomRightIcon: {
    width: 24,
    height: 24,
    marginLeft: 8,
  },
});
export default ControllerView;
