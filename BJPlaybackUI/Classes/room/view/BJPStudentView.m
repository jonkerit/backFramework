//
//  BJPUserVideoView.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2020/3/10.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJPStudentView.h"
//#import <BJVideoPlayerCore/BJVPlayerManager+playback.h>
#import "MBProgressHUD+bjpb.h"

@interface BJPStudentView()

@property (nonatomic) BJVPlayerManager *playerManager;
@property (nonatomic) UILabel *userIdLabel;
@property (nonatomic, readwrite) BJVUserVideo *userVideoInfo;

@end

@implementation BJPStudentView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithUserVideo:[BJVUserVideo new]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithUserVideo:[BJVUserVideo new]];
}

- (instancetype)initWithUserVideo:(BJVUserVideo *)userVideoInfo {
    if (!userVideoInfo.userId.length) {
        NSAssert(0, @"userVideo.userId 不能为空");
    }
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup:userVideoInfo];
        self.userVideoInfo = userVideoInfo;
        self.hidden = YES;
    }
    return self;
}

- (void)updateMediaState:(BJVMediaUser *)mediaUser {
    self.userIdLabel.text = mediaUser.name;
    self.hidden = !mediaUser.videoOn;
}

- (void)play {
    [self.playerManager play];
}

- (void)seekToTime:(NSTimeInterval)toTime {
    self.hidden = YES;
    [self.playerManager seek:toTime];
}

- (void)pause {
    [self.playerManager pause];
}

- (void)setup:(BJVUserVideo *)userVideoInfo {

    self.userIdLabel = [UILabel new];
    self.userIdLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.userIdLabel.textAlignment = NSTextAlignmentCenter;
    self.userIdLabel.textColor = [UIColor blackColor];
    [self addSubview:self.userIdLabel];
    
//    BJVPlayInfo *playInfo = [[BJVPlayInfo alloc] initWithUserVideoInfo:userVideoInfo];
    self.playerManager = [[BJVPlayerManager alloc] initWithPlayerType:BJVPlayerType_AVPlayer];
    
    [self addObserverForPlayer];
    
    [self addSubview:self.playerManager.playerView];
    
//    [self.playerManager setupVideoWithPlayInfo:playInfo];
    
    [self.userIdLabel bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    [self.playerManager.playerView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.userIdLabel.bjl_top);
    }];
    
}

- (void)addObserverForPlayer {
    bjl_weakify(self);
    // 播放状态变化
    [self bjl_kvo:BJLMakeProperty(self.playerManager, playStatus)
           filter:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
               return (old == nil) || (now.integerValue != old.integerValue);
           } observer:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
               bjl_strongify(self);
               BJVPlayerStatus status = self.playerManager.playStatus;
               
               // hud
               if (status == BJVPlayerStatus_stalled || status == BJVPlayerStatus_loading) {
                   [BJLProgressHUD bjpb_showLoading:@"正在加载" toView:self];
               }
               else {
                   [BJLProgressHUD bjpb_closeLoadingView:self];
               }
               
               
               return YES;
           }];
    
    // !!!: 播放错误，在进入回放房间成功之前添加，避免监听不到视频加载完成前的错误
    [self bjl_observe:BJLMakeMethod(self.playerManager, video:playFailedWithError:) observer:^BOOL(BJVPlayInfo *playInfo, NSError *error){
        bjl_strongify(self);
        [self studentVideo:playInfo playFailedWithError:error];
        return YES;
    }];
}

- (void)studentVideo:(BJVPlayInfo *)playInfo playFailedWithError:(NSError *)error {
    NSString *str = [NSString stringWithFormat:@"播放出错: id: %@, error: %@", self.userVideoInfo.userId, error.localizedDescription];
    [BJLProgressHUD bjpb_showMessageThenHide:str toView:[UIApplication sharedApplication].keyWindow onHide:nil];
}
@end
