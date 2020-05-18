//
//  BJPMediaSettingCell.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/14.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPMediaSettingCell.h"
#import "BJPAppearance.h"

@interface BJPMediaSettingCell ()

@property (nonatomic, strong) UIButton *optionButton;

@end

@implementation BJPMediaSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubview];
    }
    return self;
}

#pragma mark - subview

- (void)setupSubview {
    UIView *contentView = self.contentView;
    [contentView addSubview:self.optionButton];
    [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.equal.sizeOffset(CGSizeMake(BJPButtonWidth, BJPButtonHeight));
    }];
}

#pragma mark - update

- (void)updateWithSettingTitle:(NSString *)title selected:(BOOL)selected {
    [self.optionButton setTitle:title forState:UIControlStateNormal];
    self.optionButton.selected = selected;
    self.optionButton.layer.borderColor = (selected? [UIColor bjp_blueBrandColor] : [UIColor clearColor]).CGColor;
}

- (void)selectAction {
    if (self.optionButton.selected) {
        return;
    }
    
    self.optionButton.layer.borderColor = [UIColor bjp_blueBrandColor].CGColor;
    if (self.selectCallback) {
        self.selectCallback();
    }
}

#pragma mark - getters

- (UIButton *)optionButton {
    if (!_optionButton) {
        _optionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor bjp_blueBrandColor] forState:UIControlStateSelected];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 15.0;
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            [button addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _optionButton;
}

@end
