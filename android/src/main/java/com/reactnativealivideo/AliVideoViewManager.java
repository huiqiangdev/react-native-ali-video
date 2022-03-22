package com.reactnativealivideo;

import android.graphics.Color;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.bean.InfoCode;
import com.aliyun.player.nativeclass.PlayerConfig;
import com.aliyun.player.source.UrlSource;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.reactnativealivideo.widget.AliyunRenderView;

import java.util.List;
import java.util.Map;


public class AliVideoViewManager extends ViewGroupManager<AliyunRenderView> {
    public static final String REACT_CLASS = "AliVideoView";
    private static final String TAG = REACT_CLASS;
    private RCTEventEmitter mEventEmitter;

    private enum Events {
      onCompletion("onAliCompletion"),
      onError("onAliError"),
      onLoadingBegin("onAliLoadingBegin"),
      onLoadingProgress("onAliLoadingProgress"),
      onLoadingEnd("onAliLoadingEnd"),
      onPrepared("onAliPrepared"),
      onRenderingStart("onAliRenderingStart"),
      onSeekComplete("onAliSeekComplete"),
      onCurrentPositionUpdate("onAliCurrentPositionUpdate"),
      onBufferedPositionUpdate("onAliBufferedPositionUpdate"),
      onAutoPlayStart("onAliAutoPlayStart"),
      onLoopingStart("onAliLoopingStart");

      private final String mName;

      Events(final String name) {
        mName = name;
      }

      @Override
      public String toString() {
        return mName;
      }
    }
  @Nullable
  @Override
  public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder builder = MapBuilder.builder();
    for (Events event : Events.values()) {
      builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
    }
    return builder.build();
  }
  public final int COMMAND_SEEK_TO = 1;
  public final int COMMAND_START_PLAY = 2;
  public final int COMMAND_PAUSE_PLAY = 3;
  public final int COMMAND_STOP_PLAY = 4;
  public final int COMMAND_RELOAD_PLAY = 5;
  public final int COMMAND_RESTART_PLAY = 6;
  public final int COMMAND_DESTROY_PLAY = 7;
  public final int COMMAND_RESUME_PLAY = 8;
  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    MapBuilder.Builder builder = MapBuilder.builder();
    builder.put("seekTo", COMMAND_SEEK_TO);
    builder.put("startPlay", COMMAND_START_PLAY);
    builder.put("pausePlay", COMMAND_PAUSE_PLAY);
    builder.put("stopPlay", COMMAND_STOP_PLAY);
    builder.put("reloadPlay", COMMAND_RELOAD_PLAY);
    builder.put("restartPlay", COMMAND_RESTART_PLAY);
    builder.put("destroyPlay", COMMAND_DESTROY_PLAY);
    builder.put("resumePlay", COMMAND_RESUME_PLAY);

    return builder.build();
  }

  @Override
  public void addView(AliyunRenderView parent, View child, int index) {
    super.addView(parent, child, index);
  }

  @Override
  public void addViews(AliyunRenderView parent, List<View> views) {
    super.addViews(parent, views);

  }

  @Override
  public void onDropViewInstance(AliyunRenderView view) {
    super.onDropViewInstance(view);
    Log.i(TAG, "onDropViewInstance: ");
  }

  @Override
    @NonNull
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    @NonNull
    public AliyunRenderView createViewInstance(ThemedReactContext reactContext) {
      mEventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
      AliyunRenderView renderView =  new AliyunRenderView(reactContext);
      renderView.setSurfaceType(AliyunRenderView.SurfaceType.SURFACE_VIEW);
      renderView.setBackgroundColor(Color.TRANSPARENT);
      renderView.getAliPlayer().setVideoBackgroundColor(Color.TRANSPARENT);

      initListeners(renderView);

      return  renderView;
    }
    private void initListeners(AliyunRenderView view) {
      view.setOnInfoListener(new IPlayer.OnInfoListener() {
        @Override
        public void onInfo(InfoBean infoBean) {
          WritableMap event = Arguments.createMap();
          if (infoBean.getCode() == InfoCode.CurrentPosition) {
            event.putInt("position", (int) (infoBean.getExtraValue() / 1000));//转换成秒
            mEventEmitter.receiveEvent(view.getId(), Events.onCurrentPositionUpdate.toString(), event);
          } else if (infoBean.getCode() == InfoCode.BufferedPosition) {
            event.putInt("position", (int) (infoBean.getExtraValue() / 1000));//转换成秒
            mEventEmitter.receiveEvent(view.getId(), Events.onBufferedPositionUpdate.toString(), event);
          } else if (infoBean.getCode() == InfoCode.AutoPlayStart) {
            mEventEmitter.receiveEvent(view.getId(), Events.onAutoPlayStart.toString(), event);
          } else if (infoBean.getCode() == InfoCode.LoopingStart) {
            mEventEmitter.receiveEvent(view.getId(), Events.onLoopingStart.toString(), event);
          }
        }
      });
      view.setOnPreparedListener(new IPlayer.OnPreparedListener() {
        @Override
        public void onPrepared() {
          Log.i(TAG, "onPrepared: " + view.getDuration() / 1000);

          WritableMap event = Arguments.createMap();
          int duration = (int) (view.getDuration() / 1000);//转换成秒
          event.putInt("duration", duration);
          mEventEmitter.receiveEvent(view.getId(), Events.onPrepared.toString(), event);
        }
      });
      view.setOnCompletionListener(new IPlayer.OnCompletionListener() {
        @Override
        public void onCompletion() {
          Log.i(TAG, "onCompletion: ");
          WritableMap event = Arguments.createMap();
          mEventEmitter.receiveEvent(view.getId(), Events.onCompletion.toString(), event);
        }
      });
      view.setOnErrorListener(new IPlayer.OnErrorListener() {
        @Override
        public void onError(ErrorInfo errorInfo) {
          Log.i(TAG, "onError: " + errorInfo.getExtra());
          Log.i(TAG, "onError: " + errorInfo.getMsg());
          Log.i(TAG, "onError: " + errorInfo.getCode().toString());

          WritableMap event = Arguments.createMap();
          event.putString("code", errorInfo.getCode().toString());
          event.putString("message", errorInfo.getMsg());
          mEventEmitter.receiveEvent(view.getId(), Events.onError.toString(), event);
        }
      });
      view.setOnRenderingStartListener(new IPlayer.OnRenderingStartListener() {
        @Override
        public void onRenderingStart() {
          Log.i(TAG, "onRenderingStart: ");
          WritableMap event = Arguments.createMap();
          mEventEmitter.receiveEvent(view.getId(), Events.onRenderingStart.toString(), event);
        }
      });
      view.setOnSeekCompleteListener(new IPlayer.OnSeekCompleteListener() {
        @Override
        public void onSeekComplete() {
          Log.i(TAG, "onSeekComplete: ");
          WritableMap event = Arguments.createMap();
          mEventEmitter.receiveEvent(view.getId(), Events.onSeekComplete.toString(), event);
        }
      });
      view.setOnLoadingStatusListener(new IPlayer.OnLoadingStatusListener() {
        @Override
        public void onLoadingBegin() {
          Log.i(TAG, "onLoadingBegin: ");

          WritableMap event = Arguments.createMap();
          mEventEmitter.receiveEvent(view.getId(), Events.onLoadingBegin.toString(), event);

        }

        @Override
        public void onLoadingProgress(int i, float v) {
          Log.i(TAG, "onLoadingProgress: " + i);

          WritableMap event = Arguments.createMap();
          event.putInt("percent", i);
          mEventEmitter.receiveEvent(view.getId(), Events.onLoadingProgress.toString(), event);

        }

        @Override
        public void onLoadingEnd() {
          Log.i(TAG, "onLoadingEnd: ");

          WritableMap event = Arguments.createMap();
          mEventEmitter.receiveEvent(view.getId(), Events.onLoadingEnd.toString(), event);

        }
      });

    }
    @ReactProp(name= "source")
    public void setSrc(AliyunRenderView view, String src) {
      UrlSource source = new UrlSource();
      source.setUri(src);
      view.setDataSource(source);
      view.prepare();
    }
    //设置自动播放
    @ReactProp(name = "setAutoPlay")
    public void setAutoPlay(AliyunRenderView view, Boolean mode) {
      view.setAutoPlay(mode);
    }
    //设置循环播放
    @ReactProp(name = "setLoop")
    public void setLoop(AliyunRenderView view, Boolean mode) {
      view.setLoop(mode);
    }
    //设置播放器静音
    @ReactProp(name = "setMute")
    public void setMute(AliyunRenderView view, Boolean mode) {
      view.setMute(mode);
    }
  //开启硬解。默认开启
    @ReactProp(name = "enableHardwareDecoder")
    public void enableHardwareDecoder(AliyunRenderView view, Boolean mode) {
      view.enableHardwareDecoder(mode);
    }
  //设置播放器音量,范围0~1.
    @ReactProp(name = "setVolume")
    public void setVolume(AliyunRenderView view, float mode) {
      view.setVolume(mode);
    }

    //设置倍速播放:支持0.5~2倍速的播放
    @ReactProp(name = "setSpeed")
    public void setSpeed(AliyunRenderView view, float mode) {
      view.setSpeed(mode);
    }

  //设置Referer
    @ReactProp(name = "setReferer")
    public void setReferer(AliyunRenderView view, String referrer) {
      //先获取配置
      PlayerConfig config = view.getPlayerConfig();
      //设置referer
      config.mReferrer = referrer;
      //设置配置给播放器
      view.setPlayerConfig(config);
    }

  //设置UserAgent
  @ReactProp(name = "setUserAgent")
  public void setUserAgent(AliyunRenderView view, String UserAgent) {
    //先获取配置
    PlayerConfig config = view.getPlayerConfig();
    //设置UA
    config.mUserAgent = UserAgent;
    //设置配置给播放器
    view.setPlayerConfig(config);
  }

  //设置画面的镜像模式：水平镜像，垂直镜像，无镜像。
  @ReactProp(name = "setMirrorMode")
  public void setMirrorMode(AliyunRenderView view, int mode) {
    switch (mode) {
      case 0:
        view.setMirrorMode(IPlayer.MirrorMode.MIRROR_MODE_NONE);
        break;
      case 1:
        view.setMirrorMode(IPlayer.MirrorMode.MIRROR_MODE_HORIZONTAL);
        break;
      case 2:
        view.setMirrorMode(IPlayer.MirrorMode.MIRROR_MODE_VERTICAL);
        break;
    }
  }

  //设置画面旋转模式：旋转0度，90度，180度，270度
  @ReactProp(name = "setRotateMode")
  public void setRotateMode(AliyunRenderView view, int mode) {
    switch (mode) {
      case 0:
        view.setRotateModel(IPlayer.RotateMode.ROTATE_0);
        break;
      case 1:
        view.setRotateModel(IPlayer.RotateMode.ROTATE_90);
        break;
      case 2:
        view.setRotateModel(IPlayer.RotateMode.ROTATE_180);
        break;
      case 3:
        view.setRotateModel(IPlayer.RotateMode.ROTATE_270);
        break;
    }
  }

  //设置画面缩放模式：宽高比填充，宽高比适应，拉伸填充
  @ReactProp(name = "setScaleMode")
  public void setScaleMode(AliyunRenderView view, int mode) {
    switch (mode) {
      case 0:
        view.setScaleModel(IPlayer.ScaleMode.SCALE_ASPECT_FIT);
        break;
      case 1:
        view.setScaleModel(IPlayer.ScaleMode.SCALE_ASPECT_FILL);
        break;
      case 2:
        view.setScaleModel(IPlayer.ScaleMode.SCALE_TO_FILL);
        break;
    }
    view.requestLayout();
  }

  @Override
  public void receiveCommand(@NonNull AliyunRenderView root, int commandId, @Nullable ReadableArray args) {
    super.receiveCommand(root, commandId, args);
    Log.i(TAG, "receiveCommand: " + commandId);
    // This will be called whenever a command is sent from react-native.
    switch (commandId) {
      case COMMAND_START_PLAY:
        root.start();
        break;
      case  COMMAND_PAUSE_PLAY:
        root.pause();
        break;
      case COMMAND_STOP_PLAY:
        root.stop();
        break;
      case COMMAND_RELOAD_PLAY:
        root.reload();
        break;
      case COMMAND_RESTART_PLAY:
        root.seekTo(0,IPlayer.SeekMode.Accurate);
        root.start();
        break;
      case COMMAND_DESTROY_PLAY:
        root.release();
        break;
      case COMMAND_SEEK_TO:
        long position = args.getInt(1) * 1000;
        root.seekTo(position, IPlayer.SeekMode.Accurate);
        break;
      case COMMAND_RESUME_PLAY:
        break;

    }
  }
}
