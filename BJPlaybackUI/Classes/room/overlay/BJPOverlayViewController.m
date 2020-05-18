//
//  BJPOverlayViewController.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/7/2.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPOverlayViewController.h"
#import "BJPAppearance.h"

@interface BJPOverlayViewController ()

@property (nonatomic) UIView *contentView;
@property (nonatomic, weak) UIViewController *childViewController;
@property (nonatomic) UILabel *titleLabel;

@end

@implementation BJPOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

#pragma mark - subviews

- (void)setupSubviews {
    // backgroundView
    UIView *backgroundView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor bjp_lightDimColor];
        // 关闭手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [view addGestureRecognizer:tapGesture];
        view;
    });
    [self.view addSubview:backgroundView];
    [backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // content view, 约束视横竖屏而定
    [self.view addSubview:self.contentView];
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.4);
    }];
    
    // title label
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.equalTo(self.contentView.bjl_safeAreaLayoutGuide ?: self.contentView).offset(BJPViewSpaceS);
        make.right.equalTo(self.contentView.bjl_safeAreaLayoutGuide ?: self.contentView).offset(-BJPViewSpaceS);
        make.height.equalTo(@(30.0)).priorityHigh();
    }];
}

#pragma mark - public

- (void)showWithChildViewController:(UIViewController *)childViewController title:(NSString *)title {
    // title
    self.titleLabel.text = title;
    
    // childViewController
    if (self.childViewController) {
        [self.childViewController removeFromParentViewController];
    }
    [self addChildViewController:childViewController];
    [self.contentView addSubview:childViewController.view];
    [childViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bjl_bottom);
        make.left.right.equalTo(self.titleLabel);
        make.bottom.equalTo(self.contentView.bjl_safeAreaLayoutGuide ?: self.contentView);
    }];
    self.childViewController = childViewController;
    self.view.hidden = NO;
}

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    if (isHorizontal) {
        [self.contentView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.5);
        }];
    }
    else {
        [self.contentView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.5);
        }];
    }
}

#pragma mark - actions

- (void)close {
    self.titleLabel.text = nil;
    if (self.childViewController) {
        [self.childViewController.view removeFromSuperview];
        [self.childViewController removeFromParentViewController];
    }
    self.childViewController = nil;
    self.view.hidden = YES;
}

#pragma mark - getters

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:16.0];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label;
        });
    }
    return _titleLabel;
}

@end
