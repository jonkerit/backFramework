//
//  BJPReloadingView.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/26.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPReloadView.h"
#import "BJPAppearance.h"

@interface BJPReloadView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextView *detailView;
@property (nonatomic) UIButton *reloadButton;

@end

@implementation BJPReloadView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor bjp_dimColor];
        [self setupSubviews];
        self.hidden = YES;
    }
    return self;
}

#pragma mark - subViews

- (void)setupSubviews {
    // error detail
    [self addSubview:self.detailView];
    [self.detailView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.greaterThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(BJPViewSpaceL);
        make.right.lessThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-BJPViewSpaceL);
        make.height.lessThanOrEqualTo(@120.0);
        make.size.equal.sizeOffset(CGSizeZero).priorityHigh(); // to update
    }];
    
    // error title
    [self addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(BJPViewSpaceL);
        make.right.lessThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-BJPViewSpaceL);
        make.bottom.equalTo(self.detailView.bjl_top).offset(-BJPViewSpaceL);
    }];
    
    // reload button
    [self addSubview:self.reloadButton];
    [self.reloadButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.detailView.bjl_bottom).offset(BJPViewSpaceL);
        make.size.equal.sizeOffset(CGSizeMake(144.0, 40.0)).priorityHigh();
    }];
}

#pragma mark - public

- (void)showWithTitle:(NSString *)title detail:(NSString *)detail {
    self.titleLabel.text = title;
    self.detailView.text = detail;
    
    // UITextView 自适应大小
    CGSize detailSize = [self.detailView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - BJPViewSpaceL * 2, 0.0)];
    [self.detailView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.size.equal.sizeOffset(detailSize).priorityHigh();
    }];
    self.hidden = NO;
}

#pragma mark - actions

- (void)reload {
    if (self.reloadCallback) {
        self.reloadCallback();
    }
    self.hidden = YES;
}

#pragma mark - getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:18.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label;
        });
    }
    return _titleLabel;
}

- (UITextView *)detailView {
    if (!_detailView) {
        _detailView = ({
            UITextView *view = [[UITextView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.font = [UIFont systemFontOfSize:14.0];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor whiteColor];
            view.editable = NO;
            view.bounces = NO;
            view.showsVerticalScrollIndicator = NO;
            view.showsHorizontalScrollIndicator = NO;
            view;
        });
    }
    return _detailView;
}

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = ({
            UIButton *button = [UIButton new];
            [button setTitle:@"刷新重试" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor bjp_blueBrandColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = BJPButtonCornerRadius;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _reloadButton;
}

@end
