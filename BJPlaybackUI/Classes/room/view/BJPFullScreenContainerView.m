//
//  BJPFullScreenContainerView.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPFullScreenContainerView.h"
#import "BJPAppearance.h"

@interface BJPFullScreenContainerView ()

@property (nonatomic, weak) UIView *currentContentView;

@end

@implementation BJPFullScreenContainerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)replaceContentWithPPTView:(UIView *)pptView {
    // 替换内容为 PPT 视图
    [self replaceContentWithView:pptView];
    [pptView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)replaceContentWithPlayerView:(UIView *)playerView ratio:(CGFloat)ratio {
    // 替换内容为播放视图
    [self replaceContentWithView:playerView];
    [playerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (ratio > 0) {
            make.edges.equalTo(self).priorityHigh();
            make.center.equalTo(self);
            make.top.left.greaterThanOrEqualTo(self);
            make.bottom.right.lessThanOrEqualTo(self);
            make.width.equalTo(playerView.bjl_height).multipliedBy(ratio);
        }
        else {
            make.edges.equalTo(self);
        }
    }];
}

- (void)replaceContentWithView:(UIView *)view {
    //如果有父视图存在, 先移除
    if(view.superview) {
        [view removeFromSuperview];
    }
    
    // 移除现有内容
    if (self.currentContentView.superview == self) {
        [self.currentContentView removeFromSuperview];
    }
    [self insertSubview:view atIndex:0];
    self.currentContentView = view;
}

@end
