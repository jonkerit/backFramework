//
//  BJPRoomViewController+test.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2020/3/10.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJPRoomViewController+studentVideo.h"
#import "BJPRoomViewController+protected.h"

#import "BJPStudentView.h"

@implementation BJPRoomViewController (test)

- (void)creatStudentViewWithUserVideoList:(NSArray <BJVUserVideo *> *)userVideoList {
    
    if (self.userVideoDictM == nil) {
        self.userVideoDictM = [NSMutableDictionary dictionary];
    }
    
    if (userVideoList == nil) {
        return;
    }
    else {
        bjl_weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            bjl_strongify(self);
            [self addUserVideoOnMainThread:userVideoList];
        });
    }
}

- (void)updateMediaState:(BJLMediaUser *)mediaUser {
    
    if ([self.userVideoDictM.allKeys containsObject:mediaUser.ID]) {
        BJPStudentView *sView = [self.userVideoDictM objectForKey:mediaUser.ID];
        [sView updateMediaState:mediaUser];
    }
}

- (void)studentVideoShouldPlay:(BOOL)shouldPlay {
    [self.userVideoDictM enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, BJPStudentView *  _Nonnull obj, BOOL * _Nonnull stop) {
        if (shouldPlay) {
            [obj play];
        }
        else {
            [obj pause];
        }
    }];
}

- (void)studentVideoSeekTo:(NSTimeInterval)toTime {
    [self.userVideoDictM enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, BJPStudentView *  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj seekToTime:toTime];
    }];
}

- (void)addUserVideoOnMainThread:(NSArray <BJVUserVideo *> *)userVideoList {
    
    
    for (int i = 0; i < userVideoList.count; i++) {
        BJVUserVideo *userVideo = userVideoList[i];
        [self createViewWitUserVideoInfo:userVideo index:i];
    }
    
//    NSMutableArray *arr = userVideoList.mutableCopy;
//    [arr addObject:userVideoList.firstObject];
//    [arr addObject:userVideoList.firstObject];
    
//    for (int i = 0; i < arr.count; i++) {
//        BJVUserVideo *userVideo = arr[i];
//        [self createViewWitUserVideoInfo:userVideo index:i];
//    }
    
}

- (void)createViewWitUserVideoInfo:(BJVUserVideo *)userVideoInfo index:(int)i{
    
    BJPStudentView *studenView = [[BJPStudentView alloc] initWithUserVideo:userVideoInfo];
    [self.view addSubview:studenView];
    [self.userVideoDictM setObject:studenView forKey:userVideoInfo.userId];
    
    CGFloat x = 20 + i * (80 + 10);
    studenView.frame = CGRectMake(x, 30, 80, 80);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testTap:)];
    [studenView addGestureRecognizer:tap];
    
}

- (void)testTap:(UITapGestureRecognizer *)tap {
//    BJPStudentView *sView = (BJPStudentView *)tap.view;
    NSLog(@"zishu: %s, studen.userid: %@", __func__, tap.view);
}

@end
