//
//  AliVideoPlayer.m
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#import "AliVideoPlayer.h"

#import "AliyunPlayerViewControlView.h"
//data
#import "AliyunDataSource.h"

//loading
#import "AlilyunViewLoadingView.h"

static const CGFloat AlilyunViewLoadingViewWidth  = 130;
static const CGFloat AlilyunViewLoadingViewHeight = 120;

@interface AliVideoPlayer ()<AVPDelegate,AliyunControlViewDelegate>
@property (nonatomic, strong) AliPlayer *aliPlayer;               //点播播放器
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AliyunPlayerViewControlView *controlView;
@property (nonatomic, assign) AVPStatus currentPlayStatus; //记录播放器的状态
@property (nonatomic,assign) AVPSeekMode seekMode;
@property (nonatomic, strong) AlilyunViewLoadingView *loadingView;         //loading
@property (nonatomic, assign) BOOL isProtrait;                          //是否是竖屏
@property (nonatomic, assign) BOOL mProgressCanUpdate;                  //进度条是否更新，默认是NO
@property (nonatomic, assign) NSTimeInterval keyFrameTime;
#pragma mark - 播放方式
@property (nonatomic, strong) AliyunLocalSource *localSource;   //url 播放方式

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
- (AliyunPlayerViewControlView *)controlView{
    if (!_controlView) {
        _controlView = [[AliyunPlayerViewControlView alloc] init];
        [_controlView.topView.downloadButton removeFromSuperview];
        _controlView.hidden = YES; // 默认隐藏控制器
    }
    return _controlView;
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
- (AlilyunViewLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[AlilyunViewLoadingView alloc] init];
    }
    return _loadingView;
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
- (void)setViewSkin:(AliyunVodPlayerViewSkin)viewSkin{
    _viewSkin = viewSkin;
    self.controlView.skin = viewSkin;
//    self.guideView.skin = viewSkin;
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
    self.controlView.delegate = self;
    self.enableControl = false;
//    [self addSubview:self.controlView];
    
//    [self addSubview:self.loadingView];
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
        //屏幕旋转通知
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        //存储第一次触发saas
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
        if (!str) {
            [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    return  self;
}


- (void)becomeActive {
    _isEnterBackground = NO;
    if (self.currentPlayStatus == AVPStatusPaused &&_isPauseByBackground) {
        _isPauseByBackground = NO;
        [self  resume];
    }
}

- (void)resignActive {
    _isEnterBackground = YES;
    if (self.enableBackground) {
        return;
    }
    if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
        _isPauseByBackground = YES;
        [self pause];
    }
}
#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
//    float height = self.bounds.size.height;
    self.playerView.frame = self.bounds;
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    if (width >500) {
        [progressView setDotsHidden:NO];
    }else {
        [progressView setDotsHidden:YES];
    }
    self.controlView.frame = self.bounds;
    float x = (self.bounds.size.width -  AlilyunViewLoadingViewWidth)/2;
    float y = (self.bounds.size.height - AlilyunViewLoadingViewHeight)/2;
    self.loadingView.frame = CGRectMake(x, y, AlilyunViewLoadingViewWidth, AlilyunViewLoadingViewHeight);
    
}

#pragma mark - 屏幕旋转
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    
    //进后台不再旋转屏幕
    if (_isEnterBackground) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice] ;
  
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            // 影响X变成全面屏的问题
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
            if ([str isEqualToString:@"aliyun_saas_first_open"]) {
                [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_no_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 添加引导
//                [self addSubview:self.guideView];
            }
            
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            if (self.saveFrame.origin.x == 0 && self.saveFrame.origin.y==0 && self.saveFrame.size.width == 0 && self.saveFrame.size.height == 0) {
                //开始时全屏展示，self.saveFrame = CGRectZero, 旋转竖屏时做以下默认处理
                CGRect tempFrame = self.frame ;
                tempFrame.size.width = self.frame.size.height;
                tempFrame.size.height = self.frame.size.height* 9/16;
                self.frame = tempFrame;
            }else{
                self.frame = self.saveFrame;
                
            }
            //2018-6-28 cai
            BOOL isFullScreen = NO;
            if (self.frame.size.width > self.frame.size.height) {
                isFullScreen = NO;
            }
            // 移除引导
            
//            [self.guideView removeFromSuperview];
        }
            break;
        default:
            break;
    }
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
- (void)playDataSourcePropertySetEmpty{
    //保证仅存其中一种播放参数
    self.localSource = nil;
}
#pragma mark - 播放器开始播放入口
- (void)playViewPrepareWithURL:(NSURL *)url{
    
    void(^startPlayVideo)(void) = ^{
        [self playDataSourcePropertySetEmpty];
        self.localSource = [[AliyunLocalSource alloc] init];
        self.localSource.url = url;
        self.controlView.playMethod = ALYPVPlayMethodUrl;
        self.urlSource = [[AVPUrlSource alloc] urlWithString:url.absoluteString];
        [self.aliPlayer setUrlSource:self.urlSource];
        self.localSource.url =nil;
        [self.loadingView show];
        [self.aliPlayer prepare];
        
        NSLog(@"播放器prepareWithURL");
    };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
}
- (void)addAdditionalSettingWithBlock:(void(^)(void))startPlayVideo {
    
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    [progressView setAdsPart:@"0"]; // 设置都没有视频广告
    [self.controlView setButtonEnnable:YES];
    
    // 初始化进度条,把上一条播放视频的进度条 设置为0
    [self.controlView updateProgressWithCurrentTime:0 durationTime:self.aliPlayer.duration];
    [progressView removeDots];
    
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
    [self.loadingView show];
    [self.aliPlayer prepare];
    if (self.saveCurrentTime > 0) {
        [self seekTo:self.saveCurrentTime*1000];
    }
    [self.aliPlayer start];
}
- (void)destroyPlayer {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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
    self.controlView.videoInfo = mediaInfo;
    
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
            [self.loadingView dismiss];
            AVPTrackInfo * info = [player getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
            self.currentTrackInfo = info;
            self.videoTrackInfo = [player getMediaInfo].tracks;
            [self.controlView setBottomViewTrackInfo:info];
            
            
            [self updateControlLayerDataWithMediaInfo:nil];
          
            
            
            // 加密视频不支持投屏 非mp4 mov视频不支持airplay
            
            
        }
            break;
        case AVPEventFirstRenderedStart: {
            // 首帧显示
              if (self.onAliRenderingStart) {
                self.onAliRenderingStart(@{@"code":@"onRenderingStart"});
              }
            [self.loadingView dismiss];
            
            [self.controlView setEnableGesture:YES];
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
            [self.loadingView show];
        }
            break;
        case AVPEventLoadingEnd: {
            // 缓冲完成
          if (self.onAliLoadingEnd) {
            self.onAliLoadingEnd(@{@"code":@"onAliLoadingEnd"});
          }
            [self.loadingView setHidden:YES];
        }
            break;
        case AVPEventSeekEnd:{
            // 跳转完成
          if (self.onAliSeekComplete) {
            self.onAliSeekComplete(@{@"code":@"onAliSeekComplete"});
          }
            self.currentPlayStatus = AVPStatusCompletion;
        
            [self.loadingView dismiss];
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
    [self.loadingView dismiss];
    
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
        [self.controlView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
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
    self.controlView.loadTimeProgress = (float)position/player.duration;
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
//        self.trackHasThumbnai = YES;
    }else {
//        self.trackHasThumbnai = NO;
    }
    self.controlView.info = info;
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
    [self.loadingView dismiss];
    [self.controlView setBottomViewTrackInfo:info];
//    NSString *showString = [NSString stringWithFormat:@"%@%@",[@"已为你切换至" localString],[info.trackDefinition localString]];
//    [MBProgressHUD showMessage:showString inView:[UIApplication sharedApplication].keyWindow];
}

/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle {
//    CGSize subtitleSize = [self getSubTitleLabelFrameWithSubtitle:subtitle];
//    self.subTitleLabel.frame = CGRectMake((self.frame.size.width-subtitleSize.width)/2, [AliyunUtil isInterfaceOrientationPortrait]?20:64, subtitleSize.width, subtitleSize.height);
//    self.subTitleLabel.center = self.center;
//    self.subTitleLabel.text = subtitle;
//    self.subTitleLabel.hidden = NO;
}

//- (CGSize)getSubTitleLabelFrameWithSubtitle:(NSString *)subtitle {
//    NSArray *subsectionArray = [subtitle componentsSeparatedByString:@"\n"];
//    CGFloat maxWidth = 0;
//    for (NSString *subsectionTitle in subsectionArray) {
//        NSDictionary *dic = @{NSFontAttributeName:self.subTitleLabel.font};
//        CGRect rect = [subsectionTitle boundingRectWithSize:CGSizeMake(9999, 18) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil];
//        if (rect.size.width > maxWidth) { maxWidth = rect.size.width; }
//    }
//    return CGSizeMake(maxWidth + 10 , 18 * subsectionArray.count + 10 );
//}

/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 */
- (void)onSubtitleHide:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID {
//    self.subTitleLabel.hidden = YES;
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
    NSLog(@"播放器状态更新：%lu",(unsigned long)newStatus);
    if(!self.enableBackground && _isEnterBackground){
        if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
            [self pause];
        }
    }
    //更新UI状态
    [self.controlView updateViewWithPlayerState:self.currentPlayStatus isScreenLocked:false fixedPortrait:self.isProtrait];
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

/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 @see AVPImage
 */
- (void)onCaptureScreen:(AliPlayer*)player image:(AVPImage*)image {
    if (!image) {
//        [MBProgressHUD showMessage:[@"截图为空" localString]  inView:self];
        return;
    }
//    [AlivcLongVideoCommonFunc saveImage:image inView:self];
}

/**
@brief SEI回调
@param type 类型
@param data 数据
@see AVPImage
*/
- (void)onSEIData:(AliPlayer*)player type:(int)type data:(NSData *)data {
    NSString *str = [NSString stringWithUTF8String:data.bytes];
    NSLog(@"SEI: %@ %@", data, str);
}
#pragma mark - AliyunControlViewDelegate
- (void)onBackViewClickWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
//    if(self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunVodPlayerView:)]){
//        [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
//    } else {
//        [self stop];
//    }
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        [AliyunUtil setFullOrHalfScreen];
        if (self.onAliFullScreen) {
            self.onAliFullScreen(@{@"isFull":@(true)});
        }
    }else {
        if (self.onAliFullScreen) {
            self.onAliFullScreen(@{@"isFull":@(false)});
        }
        [self stop];
    }
}

- (void)onDownloadButtonClickWithAliyunControlView:(AliyunPlayerViewControlView *)controlViewP{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadButtonClickWithAliyunVodPlayerView:)]) {
//        [self.delegate onDownloadButtonClickWithAliyunVodPlayerView:self];
//    }
}

- (void)onClickedPlayButtonWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    AVPStatus state = [self playerViewState];
    if (state == AVPStatusStarted){
        //如果是直播则stop
        if (self.aliPlayer.duration==0) {
            [self stop];
        }else{
            [self pause];
        }
    }else if (state == AVPStatusPrepared){
        [self.aliPlayer start];
    }else if(state == AVPStatusPaused){
        [self resume];
    }else if (state == AVPStatusStopped){
       
            [self resume];

    } else if (state == AVPStatusCompletion) {
        [self replay];
    }
}

-(void)onClickedfullScreenButtonWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    
    if(self.fixedPortrait){
        controlView.lockButton.hidden = self.isProtrait;
        if(!self.isProtrait){
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.isProtrait = YES;
        }else{
            self.frame = self.saveFrame;
            self.isProtrait = NO;
        }
        
//        if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
//            [self.delegate aliyunVodPlayerView:self fullScreen:self.isProtrait];
//        }
    }else{
//        if(self.isScreenLocked){
//            return;
//        }
        
//        if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
//            [self.delegate aliyunVodPlayerView:self fullScreen:self.isProtrait];
//        }
        [AliyunUtil setFullOrHalfScreen];
    }
    controlView.isProtrait = self.isProtrait;
    [self setNeedsLayout];
}

- (void)aliyunControlView:(AliyunPlayerViewControlView *)controlView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event{
    
    NSInteger totalTime = 0;
//    if ([self isVideoAds]) {
//        totalTime = self.aliPlayer.duration + _adsPlayerView.seconds * 3 *1000;
//    }else {
        totalTime = self.aliPlayer.duration;
//    }
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    
    if(totalTime==0){
        [progressView.playSlider setEnabled:NO];
        return;
    }
    
    switch (event) {
        case UIControlEventTouchDown: {
            if ( progressView.playSlider.isSupportDot == YES) {
//                NSInteger dotTime = [self.dotView checkIsTouchOntheDot:totalTime *progressValue inScope:totalTime * 0.05];
//                if (dotTime >0) {
//                    if (self.dotView.hidden == YES ) {
//                        self.dotView.hidden = NO;
//                        CGFloat x = progressView.frame.origin.x;
//                        CGFloat progressWidth = progressView.frame.size.width;
//                        self.dotView.frame = CGRectMake(x+progressWidth *progressValue, 280, 150, 30);
//                        [self.dotView showViewWithTime:dotTime];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            self.dotView.hidden = YES;
//                        });
//                    }
//                }
            }
        }
            break;
        case UIControlEventValueChanged: {
            self.mProgressCanUpdate = NO;
            //更新UI上的当前时间
            [self.controlView updateCurrentTime:progressValue*totalTime durationTime:totalTime];
//            if (self.trackHasThumbnai == YES) {
//                [self.aliPlayer getThumbnail:totalTime *progressValue];
//            }
        }
            break;
//        case UIControlEventTouchCancel:
        case UIControlEventTouchUpOutside:
        case UIControlEventTouchUpInside: {
//            self.thumbnailView.hidden = YES;
//            if (self.stsSource.playConfig  && progressValue *self.aliPlayer.duration > 300*1000) {
//
//                self.previewView.hidden = NO;
//                [self.adsPlayerView releaseAdsPlayer];
//                [self.adsPlayerView removeFromSuperview];
//                self.adsPlayerView = nil;
//                [self.aliPlayer stop];
//            }else if ([self isVideoAds]) {
//                CGFloat seek = [_adsPlayerView allowSeek:progressValue];
//                if (seek == 0) {
//                    //  在广告播放期间不能seek
//                    return;
//                }else if (seek == 1.0){
//
//                    // 正常seek
//                    NSTimeInterval seekTime = [_adsPlayerView seekWithProgressValue:progressValue];
//                    [self seekTo:seekTime];
//                }else if (seek == 2){
//                    // 跳跃广告的seek，直接播放广告
//                    self.mProgressCanUpdate = YES;
//                    return;
//                }
//            } else {
                [self seekTo:progressValue*self.aliPlayer.duration];
//            }
            NSLog(@"t播放器测试：TouchUpInside 跳转到%.1f",progressValue*self.aliPlayer.duration);
            AVPStatus state = [self playerViewState];
            if (state == AVPStatusPaused) {
                [self.aliPlayer start];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
            //点击事件
        case UIControlEventTouchDownRepeat:{
            
            self.mProgressCanUpdate = NO;
//            if ([self isVideoAds]) {
//                NSTimeInterval seekTime = [_adsPlayerView seekWithProgressValue:progressValue];
//                [self seekTo:seekTime];
//            }else {
                NSLog(@"UIControlEventTouchDownRepeat::%f",progressValue);
                [self seekTo:progressValue*self.aliPlayer.duration];
//            }
            NSLog(@"t播放器测试：DownRepeat跳转到%.1f",progressValue*self.aliPlayer.duration);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
            
        case UIControlEventTouchCancel:
            self.mProgressCanUpdate = YES;
//            self.thumbnailView.hidden = YES;
            break;
            
        default:
            self.mProgressCanUpdate = YES;
            break;
    }
}

- (void)aliyunControlView:(AliyunPlayerViewControlView *)controlView qualityListViewOnItemClick:(int)index{
    
    //切换清晰度
    if ( self.currentTrackInfo.trackIndex == index) {
        
//        NSString *showString = [NSString stringWithFormat:@"%@%@",[@"当前清晰度为" localString],[_currentTrackInfo.trackDefinition localString]];
//        [MBProgressHUD showMessage:showString inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    [self.loadingView show];
    [self.aliPlayer selectTrack:index];
    if(self.currentPlayStatus == AVPStatusPaused){
        [self resume];
    }
}

#pragma mark - controlViewDelegate
- (void)onLockButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    controlView.lockButton.selected = !controlView.lockButton.isSelected;
//    self.isScreenLocked =controlView.lockButton.selected;
//    //锁屏判定
//    [controlView lockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
//    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:lockScreen:)]) {
//        BOOL lScreen = self.isScreenLocked;
//        if (self.isProtrait) {
//            lScreen = YES;
//        }
//        [self.delegate aliyunVodPlayerView:self lockScreen:lScreen];
//    }
}

- (void)onSendTextButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView*)controlView {
  
    NSLog(@"发送弹幕");
}

- (void)onSnapshopButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView*)controlView {
    NSLog(@"截图");
    
    [self.aliPlayer snapShot];
}

- (void)onSpeedViewClickedWithAliyunControlView:(AliyunPlayerViewControlView *)controlView {
//    [self.moreView showSpeedViewMoveInAnimate];
}

- (void)aliyunControlView:(AliyunPlayerViewControlView*)controlView selectTrackIndex:(NSInteger)trackIndex {
    [self.aliPlayer selectTrack:(int)trackIndex];
}

#pragma mark - loading动画
- (void)loadAnimation {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
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
- (void)controlViewEnable:(BOOL)enable {
    if (enable == NO) {
        [self.controlView showViewWithOutDelayHide];
    }else {
        [self.controlView showView];
    }
}
#pragma mark -RN 暴露的属性
- (void)setSource:(NSString *)source {
    _source = source;
    if (source.length == 0 ){
        self.controlView.hidden = YES;
        return;
    } else{
        self.controlView.hidden = false;
        [self playViewPrepareWithURL:[NSURL URLWithString:source]];
        
    }
    
}
- (void)setEnableControl:(BOOL)enableControl {
    _enableBackground = enableControl;
    self.controlView.hidden = !enableControl;
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
