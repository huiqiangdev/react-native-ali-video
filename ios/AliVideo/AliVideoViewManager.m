#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridgeModule.h>
#import "AliVideoPlayer.h"

@interface AliVideoViewManager : RCTViewManager
@end

@implementation AliVideoViewManager

RCT_EXPORT_MODULE(AliVideoView)
//暴露属性
RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(setAutoPlay, BOOL)
RCT_EXPORT_VIEW_PROPERTY(setLoop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(setMute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enableHardwareDecoder, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enableControl, BOOL)
RCT_EXPORT_VIEW_PROPERTY(setVolume, float)
RCT_EXPORT_VIEW_PROPERTY(setSpeed, float)
RCT_EXPORT_VIEW_PROPERTY(setReferer, NSString)
RCT_EXPORT_VIEW_PROPERTY(setUserAgent, NSString)
RCT_EXPORT_VIEW_PROPERTY(setMirrorMode, int)
RCT_EXPORT_VIEW_PROPERTY(setRotateMode, int)
RCT_EXPORT_VIEW_PROPERTY(setScaleMode, int)
//暴露方法（原生调用，js回调）
RCT_EXPORT_VIEW_PROPERTY(onAliCompletion, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliError, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliLoadingBegin, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliLoadingProgress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliLoadingEnd, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliPrepared, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliRenderingStart, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliSeekComplete, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliCurrentPositionUpdate, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliBufferedPositionUpdate, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliAutoPlayStart, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliLoopingStart, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAliFullScreen, RCTBubblingEventBlock)



//暴露方法（js调用，原生回调）
RCT_EXPORT_METHOD(startPlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
        [aliPlayer start];
    }];
}
RCT_EXPORT_METHOD(pausePlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
        [aliPlayer pause];
    }];
}
RCT_EXPORT_METHOD(stopPlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
         [aliPlayer stop];
     }];
}
RCT_EXPORT_METHOD(reloadPlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
         [aliPlayer reload];
     }];
}
RCT_EXPORT_METHOD(restartPlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
         [aliPlayer replay];
     }];
}
RCT_EXPORT_METHOD(destroyPlay:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
         [aliPlayer releasePlayer];
     }];
}
RCT_EXPORT_METHOD(seekTo:(nonnull NSNumber *) reactTag viewId:(nonnull NSNumber *)viewId andPosition:(nonnull NSNumber *) positon){
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        AliVideoPlayer * aliPlayer  = (AliVideoPlayer *) viewRegistry[reactTag];
         [aliPlayer seekTo:[positon intValue] * 1000];
     }];
}

- (UIView *)view
{
    AliVideoPlayer * player = [[AliVideoPlayer alloc] init];
    return player;
}

//RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIView)
//{
//  [view setBackgroundColor:[self hexStringToColor:json]];
//}
//
//- hexStringToColor:(NSString *)stringToConvert
//{
//  NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
//  NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
//
//  unsigned hex;
//  if (![stringScanner scanHexInt:&hex]) return nil;
//  int r = (hex >> 16) & 0xFF;
//  int g = (hex >> 8) & 0xFF;
//  int b = (hex) & 0xFF;
//
//  return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
//}

@end
