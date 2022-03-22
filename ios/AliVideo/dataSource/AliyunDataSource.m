//
//  AliyunDataSource.m
//  react-native-ali-video
//
//  Created by HQ on 2022/3/15.
//

#import "AliyunDataSource.h"

@implementation AliyunLocalSource

- (instancetype)init{
    if (self = [super init]) {
        _url = nil;
    }
    return self;
}

- (BOOL)isFileUrl{
    if (_url && _url.fileURL) {
        return YES;
    }
    return NO;
}

@end
