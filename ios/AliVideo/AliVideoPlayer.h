//
//  AliVideoPlayer.h
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AliyunVodPlayerViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface AliVideoPlayer : UIView


//定义要暴露属性
@property(nonatomic,strong) NSString * source;
@property(nonatomic,assign) BOOL  setAutoPlay;
@property(nonatomic,assign) BOOL  setLoop;
@property(nonatomic,assign) BOOL  setMute;
@property(nonatomic,assign) BOOL  enableControl;
@property(nonatomic,assign) BOOL  enableHardwareDecoder;
@property(nonatomic,assign) BOOL  enableBackground;
@property(nonatomic,assign) BOOL  enableAutoDestroy;
@property(nonatomic,assign) float  setVolume;
@property(nonatomic,assign) float  setSpeed;
@property(nonatomic,strong) NSString * setReferer;
@property(nonatomic,strong) NSString * setUserAgent;
@property(nonatomic,assign) int  setMirrorMode;
@property(nonatomic,assign) int  setRotateMode;
@property(nonatomic,assign) int  setScaleMode;

//定义要暴露的事件
@property (nonatomic, copy) RCTBubblingEventBlock onAliCompletion;
@property (nonatomic, copy) RCTBubblingEventBlock onAliError;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingBegin;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingProgress;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingEnd;
@property (nonatomic, copy) RCTBubblingEventBlock onAliPrepared;
@property (nonatomic, copy) RCTBubblingEventBlock onAliRenderingStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliSeekComplete;
@property (nonatomic, copy) RCTBubblingEventBlock onAliCurrentPositionUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onAliBufferedPositionUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onAliAutoPlayStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoopingStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliFullScreen;

/**
 功能：初始化界面皮肤
 备注：默认皮肤为蓝色
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin viewSkin;

/**
 * 功能：循环播放控制
 */
@property(nonatomic, readwrite)  BOOL circlePlay;
/**
 * 功能：当前播放视频支持的清晰度信息。
 */
@property  (nonatomic, strong) NSArray <AVPTrackInfo *>* videoTrackInfo;

@property (nonatomic, assign)  BOOL fixedPortrait;
/**
 *功能：播放器初始化视频，主要目的是分析视频内容，读取视频头信息，解析视频流中的视频和音频信息，并根据视频和音频信息去寻找解码器，创建播放线程等
 *参数：url，输入的url，包括本地地址和网络视频地址
 *备注：调用该函数完成后立即返回，需要等待准备完成通知，收到该通知后代表视频初始化完成，视频准备完成后可以获取到视频的相关信息。
 使用本地地址播放，注意用户需要传 NSURL 类型数据，不是NSSting 类型数据。
 本地视频播放，AliyunVodPlayerManagerDelegate在AliyunVodPlayerEventPrepareDone 状态下，某些参数无法获取（如：视频标题、清晰度）
 */
- (void)playViewPrepareWithURL:(NSURL *)url;
/**
 功能：设置是否自动播放
 参数：
 autoPlay：YES为自动播放
 */
- (void)setAutoPlay:(BOOL)autoPlay;
/**
 功能：开始播放视频
 备注：在prepareWithVid之后可以调用start进行播放。
 */
- (void)start;

/**
 功能：停止播放视频
 */
- (void)stop;

/**
 功能：重载播放
 */
- (void)reload;

/**
 功能：暂停播放视频
 */
- (void)pause;

/**
 功能：继续播放视频，此功能应用于pause之后，与pause功能匹配使用
 */
- (void)resume;
/**
 功能：seek到某个时间播放视频
 */
- (void)seekTo:(NSTimeInterval)seekTime;
/**
 功能：重播
 */
- (void)replay;

/**
 功能：停止播放销毁图层
 */
- (void)reset;

/**
功能：重试
*/
- (void)retry;

/**
 功能：释放播放器
 */
- (void)releasePlayer;

/**
 * 功能：声音调节
 */
- (void)setVolume:(float)volume;

/**
 URLSource播放源
 */
@property (nonatomic,strong) AVPUrlSource *urlSource;

/**
 * 功能：当前播放视频的清晰度信息。
 */
@property (strong, nonatomic) AVPTrackInfo *currentTrackInfo;
- (void)controlViewEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
