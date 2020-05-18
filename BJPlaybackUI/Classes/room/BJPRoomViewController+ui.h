//
//  BJPRoomViewController+ui.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/11.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPRoomViewController.h"

@interface BJPRoomViewController (ui)

- (void)setupSubviews;

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal;

- (void)updatePlayerViewConstraint;

- (void)switchViewToFullScreen:(UIView *)view;

- (void)closeThumbnailViewWithContentView:(UIView *)contentView;

- (void)cleanOverlayViews;

- (void)updateAudioOnlyImageViewHidden;

- (void)updateRateSettingViewAndShow:(BOOL)show;

- (void)updateDefinitionSettingViewAndShow:(BOOL)show;

- (void)updateConstraintsWhenEnterRoomSuccess;

@end
