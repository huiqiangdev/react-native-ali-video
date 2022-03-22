import * as React from 'react';
import { useRef, useState } from 'react';

import {
  Button,
  LayoutChangeEvent,
  LayoutRectangle,
  StyleSheet,
  View,
} from 'react-native';
import VideoPlayer from 'react-native-ali-video';
import type { VideoPlayerHandler } from '../../src/PlayTypes';

export default function App() {
  const [layout, setLayout] = useState<LayoutRectangle>({
    x: 0,
    y: 0,
    height: 0,
    width: 0,
  });
  const onLayout = (event: LayoutChangeEvent) => {
    setLayout(event.nativeEvent.layout);
  };
  const ref = useRef<VideoPlayerHandler>(null);
  const restart = () => {
    console.log('restart');
    ref.current?.play();
  };
  return (
    <View onLayout={onLayout} style={[styles.container]}>
      <Button
        onPress={() => {
          restart();
        }}
        title={'重播'}
      />
      <VideoPlayer
        ref={ref}
        enableBackground={true}
        source={
          'http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4'
        }
        setAutoPlay={true}
        style={[styles.box, { width: layout.width, height: 200 }]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: '100%',
    height: 400,
  },
});
