//
//  BJPThumbnailContainerView.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPThumbnailContainerView.h"
#import "BJPAppearance.h"

@interface BJPThumbnailContainerView ()

@property (nonatomic) BOOL touchMoveEnable;
@property (nonatomic) UIButton *titleButton;
@property (nonatomic) UIButton *closeButton;

@end

@implementation BJPThumbnailContainerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        // subview
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subviews

- (void)setupSubviews {
    // titleButton
    [self addSubview:self.titleButton];
    [self addSubview:self.closeButton];

    [self.titleButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
    }];
    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.top.right.equalTo(self);
        make.width.height.equalTo(@(20));
    }];
}

#pragma mark - action

- (void)tapAction {
    if (self.tapCallback) {
        self.tapCallback(self.currentContentView);
    }
}
- (void)closeAction{
    if (self.closeCallback) {
        self.closeCallback(self.currentContentView);
    }
}
#pragma mark - public

- (void)replaceContentWithPPTView:(UIView *)pptView {
    [self replaceContentWithView:pptView];
    [pptView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    // 显示/隐藏 名字及占位图
    self.titleButton.hidden = YES;
}

- (void)replaceContentWithPlayerView:(UIView *)playerView ratio:(CGFloat)ratio {
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
    // 显示/隐藏 名字及占位图
    self.titleButton.hidden = YES;
}

- (void)replaceContentWithView:(UIView *)view {
    if (self.currentContentView.superview == self) {
        [self.currentContentView removeFromSuperview];
    }
    
    // 添加新内容
    [self insertSubview:view belowSubview:self.titleButton];
    self.currentContentView = view;
}

- (void)setTouchMoveEnable:(BOOL)enable {
    _touchMoveEnable = enable;
}

- (void)setTitle:(nullable NSString *)title {
    [self.titleButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - touch & move

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *superview = self.superview;
    if (!superview || !self.touchMoveEnable) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:superview];
    // 上一个触摸点
    CGPoint previousPoint  = [touch previousLocationInView:superview];
    // 计算偏移量
    CGFloat offsetX = (self.center.x - superview.center.x) + (currentPoint.x - previousPoint.x);
    CGFloat offsetY = (self.center.y - superview.center.y) + (currentPoint.y - previousPoint.y);
    
    CGSize currentSize = self.bounds.size;
    [self bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        // 使用中心点约束，优先级低于边界限制
        make.centerX.equalTo(superview).offset(offsetX).priorityHigh();
        make.centerY.equalTo(superview).offset(offsetY).priorityHigh();
        // 保持原视图大小
        make.size.equal.sizeOffset(currentSize);
        // 边界限制
        make.top.left.greaterThanOrEqualTo(superview);
        make.bottom.right.lessThanOrEqualTo(superview);
    }];
}

#pragma mark - getters

- (UIButton *)titleButton {
    if (!_titleButton) {
        _titleButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage bjp_imageNamed:@"bjp_bg_name"] forState:UIControlStateNormal];
            button.tintColor = [UIColor whiteColor];
            button.enabled = NO;
            button;
        });
    }
    return _titleButton;
}
- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage bjp_imageNamed:@"bjlClose"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;;
}
@end
