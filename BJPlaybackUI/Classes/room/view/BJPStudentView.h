//
//  BJPUserVideoView.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2020/3/10.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPStudentView : UIView

- (instancetype)initWithUserVideo:(BJVUserVideo *)userVideoInfo NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) BJVUserVideo *userVideoInfo;

- (void)updateMediaState:(BJVMediaUser *)mediaUser;

- (void)play;
- (void)pause;
- (void)seekToTime:(NSTimeInterval)toTime;

@end

NS_ASSUME_NONNULL_END
