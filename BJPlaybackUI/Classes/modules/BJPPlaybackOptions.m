//
//  BJPPlaybackOptions.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/5.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPPlaybackOptions.h"

@implementation BJPPlaybackOptions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sliderDragEnabled = YES;
    }
    return self;
}

#pragma mark - <YYModel>

- (void)encodeWithCoder:(NSCoder *)aCoder { [self bjlyy_modelEncodeWithCoder:aCoder]; }
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self bjlyy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(nullable NSZone *)zone { return [self bjlyy_modelCopy]; }
- (NSUInteger)hash { return [self bjlyy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self bjlyy_modelIsEqual:object]; }

@end
