//
//  AliyunDataSource.h
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#import <Foundation/Foundation.h>

@interface AliyunLocalSource : NSObject

@property (nonatomic, strong) NSURL *url;

//本地播放地址判断
- (BOOL)isFileUrl;

@end
