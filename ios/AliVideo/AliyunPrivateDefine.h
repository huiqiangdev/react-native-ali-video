//
//  AliyunPrivateDefine.h
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#ifndef AliyunPrivateDefine_h
#define AliyunPrivateDefine_h

#import "AliyunUtil.h"
// 播控事件中的类型
#define kALYPVColorBlue                          [UIColor colorWithRed:(0 / 255.0) green:(193 / 255.0) blue:(222 / 255.0) alpha:1]
#define kALYPVPopErrorViewBackGroundColor        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define kALYPVPopSeekTextColor                   [UIColor colorWithRed:55 / 255.0 green:55 / 255.0 blue:55 / 255.0 alpha:1]
#define kALYPVColorTextNomal                     [UIColor colorWithRed:(231 / 255.0) green:(231 / 255.0) blue:(231 / 255.0) alpha:1]
#define kALYPVColorTextGray                      [UIColor colorWithRed:(158 / 255.0) green:(158 / 255.0) blue:(158 / 255.0) alpha:1]
typedef NS_ENUM (int, ALYPVPlayMethod) {
    ALYPVPlayMethodUrl = 0,
    ALYPVPlayMethodMPS,
    ALYPVPlayMethodPlayAuth,
    ALYPVPlayMethodSTS,
    ALYPVPlayMethodLocal,
};
typedef NS_ENUM(int, ALYPVOrientation) {
    ALYPVOrientationUnknow = 0,
    ALYPVOrientationHorizontal,
    ALYPVOrientationVertical
};
#endif /* AliyunPrivateDefine_h */
