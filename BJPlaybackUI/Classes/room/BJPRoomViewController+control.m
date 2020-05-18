//
//  BJPRoomViewController+control.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/13.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPRoomViewController+control.h"
#import "BJPRoomViewController+protected.h"
#import "BJPRoomViewController+studentVideo.h"

@implementation BJPRoomViewController (control)

- (void)setupPlaybackControlCallbacks {
    // media
    [self setupMediaControlCallbacks];
    // UI
    [self setupUIControlCallbacks];
}

- (void)setupMediaControlCallbacks {
    bjl_weakify(self);
    // 退出
    [self.playbackControlView setCancelCallback:^{
        bjl_strongify(self);
        [self askToExit];
    }];
    
    // 播放
    [self.playbackControlView setMediaPlayCallback:^{
        bjl_strongify(self);
        [self.room.playerManager play];
        [self studentVideoShouldPlay:YES];
    }];
    
    // 暂停
    [self.playbackControlView setMediaPauseCallback:^{
        bjl_strongify(self);
        [self.room.playerManager pause];
        [self studentVideoShouldPlay:NO];
    }];
    
    // seek
    [self.playbackControlView setMediaSeekCallback:^(NSTimeInterval toTime) {
        bjl_strongify(self);
        [self.room.playerManager seek:toTime];
        [self studentVideoSeekTo:toTime];
    }];
    
    // 显示倍速列表
    [self.playbackControlView setShowRateListCallback:^{
        bjl_strongify(self);
        [self updateRateSettingViewAndShow:YES];
    }];
    
    // 显示清晰度列表
    [self.playbackControlView setShowDefinitionListCallback:^{
        bjl_strongify(self);
        [self updateDefinitionSettingViewAndShow:YES];
        self.mediaSettingView.hidden = NO;
    }];
    
    // 双击控制播放或暂停
    [self.playbackControlView setDoubleTapCallback:^{
        bjl_strongify(self);
        BJVPlayerStatus status = self.room.playerManager.playStatus;
        if (status == BJVPlayerStatus_playing) {
            [self.room.playerManager pause];
        }
        else if (status == BJVPlayerStatus_paused
                 || status == BJVPlayerStatus_stopped
                 || status  == BJVPlayerStatus_reachEnd
                 || status == BJVPlayerStatus_failed
                 || status == BJVPlayerStatus_ready) {
            [self.room.playerManager play];
        }
    }];
}

- (void)setupUIControlCallbacks {
    bjl_weakify(self);
    // 旋转屏幕
    [self.playbackControlView setRotateCallback:^(BOOL horizontal) {
        bjl_strongify(self);
        if (horizontal != BJPIsHorizontalUI(self)) {
            [[UIDevice currentDevice] setValue:@(horizontal ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationPortrait) forKey:@"orientation"];
            [self updateConstraintsForHorizontal:horizontal];
        }
    }];
    
    // 刷新重试
    [self.playbackControlView setReloadCallback:^{
        bjl_strongify(self);
        [self.room reload];
    }];
    
    // 选择 倍速/清晰度
    [self.mediaSettingView setSelectCallback:^(BJPMediaSettingType type, NSUInteger selectIndex) {
        bjl_strongify(self);
        if (type == BJPMediaSettingType_Rate) {
            CGFloat rate = [[self.rateList objectAtIndex:selectIndex] bjl_floatValue];
            [self.room.playerManager setRate:rate];
        }
        else if (type == BJPMediaSettingType_Definition) {
            [self.room.playerManager changeDefinitionWithIndex:selectIndex];
        }
    }];
    
    // 大小屏切换
    [self.thumbnailContainerView setTapCallback:^(UIView * _Nonnull currentContentView) {
        bjl_strongify(self);
        UIAlertControllerStyle style = self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert;
        UIAlertController *alert = [UIAlertController bjl_lightAlertControllerWithTitle:@"请选择" message:nil preferredStyle:style];
        // 切换大小屏
        UIAlertAction *switchAction = [UIAlertAction actionWithTitle:@"全屏"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self switchViewToFullScreen:currentContentView];
                                                             }];
        [alert addAction:switchAction];
        
        // 关闭小屏
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭"
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self closeThumbnailViewWithContentView:currentContentView];
                                                            }];
        [alert addAction:closeAction];
        
        // 取消
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    [self.messageViewContrller setShowImageBrowserCallback:^(UIImageView * _Nonnull imageView) {
        bjl_strongify(self);
        if (!imageView.image) {
            return;
        }
        self.imageBrowserViewController.view.alpha = 0.0;
        self.imageBrowserViewController.imageView.image = imageView.image;
        [self bjl_addChildViewController:self.imageBrowserViewController superview:self.view];
        [self.imageBrowserViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [self.imageBrowserViewController.view setNeedsLayout];
        [self.imageBrowserViewController.view layoutIfNeeded];
        [UIView animateWithDuration:BJPAnimateDurationM
                         animations:^{
                             self.imageBrowserViewController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [self setNeedsStatusBarAppearanceUpdate];
                         }];
    }];
    
    // 随控件的 显示/隐藏 更新 statusBar
    [self bjl_kvo:BJLMakeProperty(self.playbackControlView, controlsHidden)
         observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
             bjl_strongify(self);
             BOOL hidden = self.playbackControlView.controlsHidden;
             
        if (!self.room.isInteractiveClass) {
            self.controlView.usersButton.hidden = hidden;
            self.controlView.thumbnailButton.hidden = hidden ?: !self.thumbnailContainerView.hidden;
            self.controlView.messageButton.hidden = hidden;
            self.controlView.questionButton.hidden = hidden;
            [self setNeedsStatusBarAppearanceUpdate];
           }
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.overlayViewController.view, hidden)
         observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
             bjl_strongify(self);
             [self setNeedsStatusBarAppearanceUpdate];
             return YES;
         }];
}

- (void)setControlViewCallback {
    bjl_weakify(self);
    // 消息
    [self.controlView setShowMessageCallback:^(BOOL show) {
        bjl_strongify(self);
        self.messageViewContrller.view.hidden = !show;
    }];
    
    // 显示小屏
    [self.controlView setShowThumbnailCallback:^{
        bjl_strongify(self);
        self.thumbnailContainerView.hidden = NO;
        self.controlView.thumbnailButton.hidden = YES;
    }];
    
    // 用户列表
    [self.controlView setShowUsersCallback:^{
        bjl_strongify(self);
        [self.overlayViewController showWithChildViewController:self.usersViewController title:@"用户列表"];
    }];
    
    // 问答
    [self.controlView setShowQuestionCallback:^{
        bjl_strongify(self);
        [self.overlayViewController showWithChildViewController:self.questionViewController title:@"问答"];
    }];
}

@end
