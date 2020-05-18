//
//  BJPRoomViewController+test.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2020/3/10.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//


#import "BJPRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface BJPRoomViewController (test)

/// 创建学生视频
/// @param userVideoList 学生视频列表
- (void)creatStudentViewWithUserVideoList:(NSArray <BJVUserVideo *> *)userVideoList;

/// 更新学生视频, 当mediaUser.videoOn == NO, 隐藏学生视频, 反之展示.
/// @param mediaUser 上麦学生的音视频信息
- (void)updateMediaState:(BJLMediaUser *)mediaUser;

/// 是否播放学生视频, 由主视频的播放按钮控制
/// @param shouldPlay shouldPlay 
- (void)studentVideoShouldPlay:(BOOL)shouldPlay;

/// seek
/// @param toTime toTime
- (void)studentVideoSeekTo:(NSTimeInterval)toTime;

@end

NS_ASSUME_NONNULL_END
