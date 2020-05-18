//
//  BJPRoomViewController+ui.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/11.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPRoomViewController+ui.h"
#import "BJPRoomViewController+protected.h"

@implementation BJPRoomViewController (ui)

#pragma mark - subViews

// 默认创建普通大班课的布局
- (void)setupSubviews {
    // fullScreenContainerView: 默认显示 PPT 视图
    [self.view addSubview:self.fullScreenContainerView];
    [self bjl_addChildViewController:self.room.slideshowViewController];
    [self.fullScreenContainerView replaceContentWithPPTView:self.room.slideshowViewController.view];
    
    // play back control
    [self.view addSubview:self.playbackControlView];
    [self.playbackControlView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.bottom.right.equalTo(self.fullScreenContainerView);
    }];
    
    // messageView
    [self bjl_addChildViewController:self.messageViewContrller superview:self.view];
    
    // thumbnailContainerView: 默认显示播放器视图
    [self.view addSubview:self.thumbnailContainerView];
    [self.thumbnailContainerView replaceContentWithPlayerView:self.room.playerManager.playerView ratio:self.videoRatio];
    
    // video off image view
    [self.room.playerManager.playerView addSubview:self.audioOnlyImageView];
    [self.audioOnlyImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.room.playerManager.playerView);
    }];
    
    // media setting view
    [self.view addSubview:self.mediaSettingView];
    [self.mediaSettingView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.fullScreenContainerView);
    }];
    
    // contols view
    [self.view addSubview:self.controlLayer];
    [self.controlLayer bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.edges.equalTo(self.view);
    }];
    
    // overlayViewController
    [self bjl_addChildViewController:self.overlayViewController superview:self.view];
    [self.overlayViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.quizContainLayer];
    [self.quizContainLayer bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - public

// 首次触发时不能获取到正确班型
- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    CGFloat statusBarHeight = MAX(20.0, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    CGSize thumbnailSize = CGSizeMake(100.0, 76.0);
    // fullScreenContainerView
    [self.fullScreenContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (isHorizontal) {
            make.edges.equalTo(self.view);
        }
        else {
            make.top.equalTo(self.view).offset(statusBarHeight);
            make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            make.height.equalTo(self.fullScreenContainerView.bjl_width).multipliedBy(3.0 / 4.0);
        }
    }];
    
    // play control view
    [self.playbackControlView updateConstraintsForHorizontal:isHorizontal];
    
    if(!self.room.isInteractiveClass) {
        // messageView
        [self.messageViewContrller.view bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            if (isHorizontal) {
                make.top.equalTo(self.fullScreenContainerView).offset(statusBarHeight + thumbnailSize.height + BJPViewSpaceS);
                make.right.equalTo(self.view.bjl_centerX);
                make.bottom.equalTo(self.playbackControlView.bjl_safeAreaLayoutGuide ?: self.playbackControlView).offset(-BJPButtonSizeL -BJPButtonSizeM - BJPViewSpaceM);
            }
            else {
                make.top.equalTo(self.fullScreenContainerView.bjl_bottom).offset(BJPViewSpaceS).priorityHigh();
                make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-thumbnailSize.width - BJPViewSpaceS);
                make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        }];
        
        // thumbnailContainerView
        [self.thumbnailContainerView setTouchMoveEnable:isHorizontal];
        [self.thumbnailContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            if (isHorizontal) {
                make.top.equalTo(self.fullScreenContainerView).offset(statusBarHeight);
                make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            else {
                make.top.equalTo(self.fullScreenContainerView.bjl_bottom);
                make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            make.size.equal.sizeOffset(thumbnailSize);
        }];
        
        // controls
        [self.controlView updateConstraintsForHorizontal:isHorizontal];
    }
    
    // overlayViewController
    [self.overlayViewController updateConstraintsForHorizontal:isHorizontal];
}

- (void)updatePlayerViewConstraint {
    UIView *playerView = self.room.playerManager.playerView;
    UIView *superview = playerView.superview;
    CGFloat ratio = self.videoRatio;
    if (!superview) {
        return;
    }
    [playerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (ratio > 0) {
            make.edges.equalTo(superview).priorityHigh();
            make.center.equalTo(superview);
            make.top.left.greaterThanOrEqualTo(superview);
            make.bottom.right.lessThanOrEqualTo(superview);
            make.width.equalTo(playerView.bjl_height).multipliedBy(ratio);
        }
        else {
            make.edges.equalTo(superview);
        }
    }];
}

- (void)switchViewToFullScreen:(UIView *)view {
    UIView *pptView = self.room.slideshowViewController.view;
    UIView *playerView = self.room.playerManager.playerView;
    if (view == pptView) {
        [self.thumbnailContainerView replaceContentWithPlayerView:playerView ratio:self.videoRatio];
        [self.fullScreenContainerView replaceContentWithPPTView:pptView];
    }
    else if (view == playerView) {
        [self.thumbnailContainerView replaceContentWithPPTView:pptView];
        [self.fullScreenContainerView replaceContentWithPlayerView:playerView ratio:self.videoRatio];
    }
}

- (void)closeThumbnailViewWithContentView:(UIView *)contentView {
    self.thumbnailContainerView.hidden = YES;
    self.controlView.thumbnailButton.selected = (contentView != self.room.playerManager.playerView);
    self.controlView.thumbnailButton.hidden = self.playbackControlView.controlsHidden;;
}

- (void)cleanOverlayViews {
    self.mediaSettingView.hidden = YES;
    [self.playbackControlView hideReloadView];
}

- (void)updateAudioOnlyImageViewHidden {
    if (self.room.playerManager.currDefinitionInfo.isAudio) {
        // 播放纯音频时，显示占位图
        self.audioOnlyImageView.hidden = NO;
        return;
    }
    
    if (self.room.playerManager.playInfo.recordType == BJRecordType_Mixed) {
        // 合流视频一直不显示占位图
        self.audioOnlyImageView.hidden = YES;
        return;
    }
    
    // 播放视频时，根据老师是否打开摄像头来显示占位图
    self.audioOnlyImageView.hidden = self.room.onlineUsersVM.currentPresenter.videoOn;
}

- (void)updateRateSettingViewAndShow:(BOOL)show {
    NSMutableArray *rateOptions = [NSMutableArray array];
    NSUInteger selectIndex = 0;
    for (int i = 0; i < self.rateList.count; i++) {
        CGFloat rate = [[self.rateList objectAtIndex:i] bjl_floatValue];
        NSString *optionKey = [NSString stringWithFormat:@"%.1fx", rate];
        [rateOptions addObject:optionKey ?: @""];
        if (fabs(rate - self.room.playerManager.rate) < 0.1) {
            selectIndex = i;
        }
    }
    
    if (show) {
        [self.mediaSettingView showWithSettingOptons:rateOptions
                                                type:BJPMediaSettingType_Rate
                                         selectIndex:selectIndex];
    }
    else {
        [self.mediaSettingView updateWithSettingOptons:rateOptions
                                                  type:BJPMediaSettingType_Rate
                                           selectIndex:selectIndex];
    }
    
}

- (void)updateDefinitionSettingViewAndShow:(BOOL)show {
    NSArray *definitionList = self.room.playerManager.playInfo.definitionList;
    BJVDefinitionInfo *currDefinitionInfo = self.room.playerManager.currDefinitionInfo;
    NSMutableArray *definitionOptions = [NSMutableArray array];
    NSUInteger selectIndex = 0;
    for (int i = 0; i < definitionList.count; i ++) {
        BJVDefinitionInfo *definitionInfo = [[definitionList bjl_objectAtIndex:i] bjl_as:[BJVDefinitionInfo class]];
        [definitionOptions addObject:definitionInfo.definitionName ?: @""];
        if ([definitionInfo.definitionKey isEqualToString:currDefinitionInfo.definitionKey]) {
            selectIndex = i;
        }
    }
    
    if (show) {
        [self.mediaSettingView showWithSettingOptons:definitionOptions
                                                type:BJPMediaSettingType_Definition
                                         selectIndex:selectIndex];
    }
    else {
        [self.mediaSettingView updateWithSettingOptons:definitionOptions
                                                  type:BJPMediaSettingType_Definition
                                           selectIndex:selectIndex];
    }
}

// 获取到配置信息，调整布局
- (void)updateConstraintsWhenEnterRoomSuccess {
    if (self.room.isInteractiveClass) {
          //PPT , chat 隐藏
           BOOL isHorizontal = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
           if (!isHorizontal) {
               [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
           }
           
           // fullScreenContainerView
           [self.fullScreenContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
               make.edges.equalTo(self.view);
           }];
           [self.fullScreenContainerView replaceContentWithPlayerView:self.room.playerManager.playerView ratio:self.videoRatio];

           self.thumbnailContainerView.hidden = YES;
           
           if(self.messageViewContrller) {
               [self.messageViewContrller bjl_removeFromParentViewControllerAndSuperiew];
           }
        
            if (self.room.slideshowViewController) {
                [self.room.slideshowViewController bjl_removeFromParentViewControllerAndSuperiew];
            }

           // play control view
           [self.playbackControlView updateViewForInteractiveClass];

           // overlayViewController
           [self.overlayViewController updateConstraintsForHorizontal:YES];
    }
    else {
        self.controlView = [[BJPControlView alloc] initWithRoom:self.room];
        [self setControlViewCallback];
        [self.controlLayer addSubview:self.controlView];
        [self.controlView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.controlLayer.bjl_safeAreaLayoutGuide ?: self.controlLayer);
        }];
        
        // question
        if (self.room.playbackInfo.enableQuestion) {
            self.questionViewController = [[BJPQuestionViewController alloc] initWithRoom:self.room];
            bjl_weakify(self);
            [self.questionViewController setShowRedDotCallback:^(BOOL show) {
                bjl_strongify(self);
                self.controlView.questionRedDot.hidden = !show;
            }];
        }
    }
}

@end
