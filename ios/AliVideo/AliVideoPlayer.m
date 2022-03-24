//
//  AliVideoPlayer.m
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#import "AliVideoPlayer.h"


static const CGFloat AlilyunViewLoadingViewWidth  = 130;
static const CGFloat AlilyunViewLoadingViewHeight = 120;

@interface AliVideoPlayer ()<AVPDelegate>
@property (nonatomic, strong) AliPlayer *aliPlayer;               //点播播放器
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) AVPStatus currentPlayStatus; //记录播放器的状态
@property (nonatomic,assign) AVPSeekMode seekMode;
@property (nonatomic, assign) BOOL isProtrait;                          //是否是竖屏
@property (nonatomic, assign) BOOL mProgressCanUpdate;                  //进度条是否更新，默认是NO
@property (nonatomic, assign) NSTimeInterval keyFrameTime;

#pragma mark -data
@property (nonatomic, assign) CGRect saveFrame;                         //记录竖屏时尺寸,横屏时为全屏状态。
@property (nonatomic, assign) float saveCurrentTime;                    //保存重试之前的播放时间

@property (nonatomic,assign) BOOL isEnterBackground;
@property (nonatomic,assign) BOOL isPauseByBackground;
@end
@implementation AliVideoPlayer

#pragma mark lazy load
- (AliPlayer *)aliPlayer {
    if (!_aliPlayer && UIApplicationStateActive ==[[UIApplication sharedApplication] applicationState]) {
        _aliPlayer = [[AliPlayer alloc] init];
        _aliPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
        _aliPlayer.rate = 1;
        _aliPlayer.delegate = self;
        _aliPlayer.playerView = self.playerView;
    }
    return _aliPlayer;
}
- (void)setAutoPlay:(BOOL)autoPlay {
    [self.aliPlayer setAutoPlay:autoPlay];
}

- (void)setCirclePlay:(BOOL)circlePlay{
    self.aliPlayer.loop = circlePlay;
}

- (BOOL)circlePlay{
    return self.aliPlayer.loop;
}
- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc]init];
    }
    return _playerView;
}
- (AVPStatus)playerViewState {
    return _currentPlayStatus;
}
- (AVPSeekMode)seekMode {
    if (self.aliPlayer.duration < 300000) {
        return AVP_SEEKMODE_ACCURATE;
    }else {
        return AVP_SEEKMODE_INACCURATE;
    }
    
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //指记录竖屏时界面尺寸
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    if (o == UIInterfaceOrientationPortrait){
        if (!self.fixedPortrait) {
            self.saveFrame = frame;
        }
    }
}
#pragma mark - init

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}
- (void)initView {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    self.keyFrameTime = 0;
    [self addSubview:self.playerView];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
        if (o == UIInterfaceOrientationPortrait) {
            self.saveFrame = frame;
        } else {
            self.saveFrame = CGRectZero;
        }
        self.mProgressCanUpdate = YES;
        // 设置view
        [self initView];
    

    }
    return  self;
}


- (void)becomeActive {
    _isEnterBackground = NO;
    if (self.currentPlayStatus == AVPStatusPaused &&_isPauseByBackground) {
        _isPauseByBackground = NO;
//        [self  resume];
    }
}

- (void)resignActive {

    _isEnterBackground = YES;
    if (self.enableBackground) {
        return;
    }
    if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
        _isPauseByBackground = YES;
//        [self pause];
    }
}
#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerView.frame = self.bounds;
    
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.aliPlayer && self.enableAutoDestroy) {
        [self releasePlayer];
    }
}

- (void)releasePlayer {
    
    [self.aliPlayer stop];
    [self.aliPlayer destroy];
}
#pragma mark - 播放器开始播放入口
- (void)playViewPrepareWithURL:(NSURL *)url{
    
    void(^startPlayVideo)(void) = ^{
        self.urlSource = [[AVPUrlSource alloc] urlWithString:url.absoluteString];
        [self.aliPlayer setUrlSource:self.urlSource];
        [self.aliPlayer prepare];
        
        NSLog(@"播放器prepareWithURL");
    };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
}
- (void)addAdditionalSettingWithBlock:(void(^)(void))startPlayVideo {
    startPlayVideo();
    [self.aliPlayer start];

}

#pragma mark - playManagerAction
- (void)start {
    [self.aliPlayer start];
}
- (void)pause {
    [self.aliPlayer pause];
    self.currentPlayStatus = AVPStatusPaused;
    NSLog(@"播放器暂停");
}
- (void)resume {
    [self.aliPlayer start];
    self.currentPlayStatus = AVPStatusStarted;
    NSLog(@"播放器resume");
    
}
- (void)seekTo:(NSTimeInterval)seekTime {
    if (self.aliPlayer.duration > 0) {
        [self.aliPlayer seekToTime:seekTime seekMode:self.seekMode];
    }
}
- (void)stop {
    [self.aliPlayer stop];
    NSLog(@"播放器stop");
}


- (void)reload {
    [self.aliPlayer reload];
    NSLog(@"播放器reload");
}

- (void)replay{
    [self.aliPlayer seekToTime:0 seekMode:self.seekMode];
    [self.aliPlayer start];
    
    self.currentPlayStatus = AVPStatusStarted;
    NSLog(@"播放器replay");
}

- (void)reset{
    [self.aliPlayer reset];
    NSLog(@"播放器reset");
}
- (void)retry {
    [self stop];
    //重试播放
    [self.aliPlayer prepare];
    if (self.saveCurrentTime > 0) {
        [self seekTo:self.saveCurrentTime*1000];
    }
    [self.aliPlayer start];
}
- (void)destroyPlayer {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.aliPlayer) {
            [self.aliPlayer destroy];
            self.aliPlayer = nil;
        }
        //开启休眠
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    });
}
#pragma mark - public method
//更新controlLayer界面ui数据
- (void)updateControlLayerDataWithMediaInfo:(AVPMediaInfo *)mediaInfo{
    //设置数据
    
}
#pragma mark - AVPDelegate
- (void)onLoadingProgress:(AliPlayer *)player progress:(float)progress {
    
    if (self.onAliLoadingProgress) {
        self.onAliLoadingProgress(@{@"percent":@(progress)});
    }
}
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    
    switch (eventType) {
        case AVPEventPrepareDone: {
            // 准备完成
            if (self.onAliPrepared) {
                self.onAliPrepared(@{@"duration":@(player.duration/1000)});
            }
            AVPTrackInfo * info = [player getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
            self.currentTrackInfo = info;
            self.videoTrackInfo = [player getMediaInfo].tracks;
            
            
            [self updateControlLayerDataWithMediaInfo:nil];
          
            
            
            // 加密视频不支持投屏 非mp4 mov视频不支持airplay
            
            
        }
            break;
        case AVPEventFirstRenderedStart: {
            // 首帧显示
              if (self.onAliRenderingStart) {
                self.onAliRenderingStart(@{@"code":@"onRenderingStart"});
              }
            //开启常亮状态
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            NSLog(@"AVPEventFirstRenderedStart--首帧回调");
        }
            break;
        case AVPEventCompletion: {
            // 播放完成
          if (self.onAliCompletion) {
            self.onAliCompletion(@{@"code":@"onAliCompletion"});
          }
            [self unlockScreen];
            
        }
            
            break;
        case AVPEventLoadingStart: {
            // 缓冲开始
          if (self.onAliLoadingBegin) {
            self.onAliLoadingBegin(@{@"code":@"onAliLoadingBegin"});
          }
        }
            break;
        case AVPEventLoadingEnd: {
            // 缓冲完成
          if (self.onAliLoadingEnd) {
            self.onAliLoadingEnd(@{@"code":@"onAliLoadingEnd"});
          }
        }
            break;
        case AVPEventSeekEnd:{
            // 跳转完成
          if (self.onAliSeekComplete) {
            self.onAliSeekComplete(@{@"code":@"onAliSeekComplete"});
          }
            self.currentPlayStatus = AVPStatusCompletion;
            NSLog(@"seekDone");
        }
            break;
        case AVPEventLoopingStart:
            // 循环播放开始
             if (self.onAliLoopingStart) {
               self.onAliLoopingStart(@{@"code":@"onAliLoopingStart"});
             }
            break;
        case AVPEventAutoPlayStart:
            // 自动播放开始事件
          if (self.onAliAutoPlayStart) {
             self.onAliAutoPlayStart(@{@"code":@"onAliAutoPlayStart"});
          }
        default:
            break;
    }
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventWithString 播放器事件类型
 @param description 播放器事件说明
 @see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    //过滤EVENT_PLAYER_DIRECT_COMPONENT_MSG 打印信息
    if (eventWithString != EVENT_PLAYER_DIRECT_COMPONENT_MSG) {
        NSLog(@"%@",description);
    }
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    //提示错误，及stop播放
     self.onAliError(@{@"code":@(errorModel.code),@"message":errorModel.message});
    //取消屏幕锁定旋转状态
    [self unlockScreen];
    //关闭loading动画
    
    //根据播放器状态处理seek时thumb是否可以拖动
    // [self.controlView updateViewWithPlayerState:self.aliPlayer.playerState isScreenLocked:self.isScreenLocked fixedPortrait:self.isProtrait];
    //根据错误信息，展示popLayer界面
    
    NSLog(@"errorCode:%lu errorMessage:%@",(unsigned long)errorModel.code,errorModel.message);
}

- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    if (self.onAliCurrentPositionUpdate) {
         self.onAliCurrentPositionUpdate(@{@"position":@(position/1000)});
    }
    NSTimeInterval currentTime = position;
    NSTimeInterval durationTime = self.aliPlayer.duration;
    self.saveCurrentTime = currentTime / 1000;
    if(self.mProgressCanUpdate == YES){
        if (self.keyFrameTime >0 && position < self.keyFrameTime) {
            // 屏蔽关键帧问题
            return;
        }
        self.keyFrameTime = 0;
    }
}

/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    if (self.onAliBufferedPositionUpdate) {
        self.onAliBufferedPositionUpdate(@{@"position":@(position/1000)});
    }
}

/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组
 @see AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    
    AVPMediaInfo* mediaInfo = [player getMediaInfo];
    if ((nil != mediaInfo.thumbnails) && (0 < [mediaInfo.thumbnails count])) {
        [player setThumbnailUrl:[mediaInfo.thumbnails objectAtIndex:0].URL];
    }
}

/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 @see AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    //选中切换
    NSLog(@"%@",info.trackDefinition);
    self.currentTrackInfo = info;
}



/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 @see AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    
    self.currentPlayStatus = newStatus;
    if(!self.enableBackground && _isEnterBackground){
        if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
            [self pause];
        }
    }
}

- (void)onGetThumbnailSuc:(int64_t)positionMs fromPos:(int64_t)fromPos toPos:(int64_t)toPos image:(id)image {
//    self.thumbnailView.time = positionMs;
//    self.thumbnailView.thumbnailImage = (UIImage *)image;
//    self.thumbnailView.hidden = NO;
}

/**
 @brief 获取缩略图失败回调
 @param positionMs 指定的缩略图位置
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs {
    NSLog(@"缩略图获取失败");
}


//取消屏幕锁定旋转状态
- (void)unlockScreen{
    //弹出错误窗口时 取消锁屏。
}

/**
 * 功能：声音调节
 */
- (void)setVolume:(float)volume{
    [self.aliPlayer setVolume:volume];
}
#pragma mark -RN 暴露的属性
- (void)setSource:(NSString *)source {
    _source = source;
    if (source.length == 0 ){
        return;
    } else{
        [self playViewPrepareWithURL:[NSURL URLWithString:source]];
        
    }
    
}
- (void)setSetAutoPlay:(BOOL)setAutoPlay {
    _setAutoPlay = setAutoPlay;
    [self.aliPlayer setAutoPlay:setAutoPlay];
}
- (void)setSetLoop:(BOOL)setLoop {
    _setLoop = setLoop;
    [self.aliPlayer setLoop:setLoop];
}
- (void)setSetMute:(BOOL)setMute{
  _setMute = setMute;
  [self.aliPlayer setMuted:setMute];
}
- (void)setEnableHardwareDecoder:(BOOL)enableHardwareDecoder{
  _enableHardwareDecoder = enableHardwareDecoder;
  [self.aliPlayer setEnableHardwareDecoder:enableHardwareDecoder];
}
- (void)setSetVolume:(float)setVolume{
  _setVolume = setVolume;
  [self.aliPlayer setVolume:setVolume];
}
- (void)setSetSpeed:(float)setSpeed{
  _setSpeed = setSpeed;
  [self.aliPlayer setRate:setSpeed];
}
- (void)setEnableBackground:(BOOL)enableBackground {
    _enableBackground = enableBackground;
    
}
- (void)setSetReferer:(NSString *)setReferer{
  _setReferer = setReferer;
  AVPConfig *config = [self.aliPlayer getConfig];
  config.referer = setReferer;
  [self.aliPlayer setConfig:config];
}
- (void)setSetUserAgent:(NSString *)setUserAgent{
  _setUserAgent = setUserAgent;
  AVPConfig *config = [self.aliPlayer getConfig];
  config.userAgent = setUserAgent;
  [self.aliPlayer setConfig:config];
}
- (void)setSetMirrorMode:(int)setMirrorMode{
  _setMirrorMode = setMirrorMode;
  switch (setMirrorMode) {
    case 0:
      [self.aliPlayer setMirrorMode:AVP_MIRRORMODE_NONE];
      break;
    case 1:
      [self.aliPlayer setMirrorMode:AVP_MIRRORMODE_HORIZONTAL];
      break;
    case 2:
      [self.aliPlayer setMirrorMode:AVP_MIRRORMODE_VERTICAL];
      break;
    default:
      break;
  }
}
-(void)setSetRotateMode:(int)setRotateMode{
  _setRotateMode = setRotateMode;
  switch (setRotateMode) {
    case 0:
      [self.aliPlayer setRotateMode:AVP_ROTATE_0];
      break;
    case 1:
      [self.aliPlayer setRotateMode:AVP_ROTATE_90];
      break;
    case 2:
      [self.aliPlayer setRotateMode:AVP_ROTATE_180];
      break;
    case 3:
      [self.aliPlayer setRotateMode:AVP_ROTATE_270];
      break;
    default:
      break;
  }
}
- (void)setSetScaleMode:(int)setScaleMode{
  _setScaleMode = setScaleMode;
  switch (setScaleMode) {
    case 0:
      [self.aliPlayer setScalingMode:AVP_SCALINGMODE_SCALEASPECTFIT];
      break;
    case 1:
      [self.aliPlayer setScalingMode:AVP_SCALINGMODE_SCALEASPECTFILL];
      break;
    case 2:
      [self.aliPlayer setScalingMode:AVP_SCALINGMODE_SCALETOFILL];
      break;
    default:
      break;
  }
}
@end
//
