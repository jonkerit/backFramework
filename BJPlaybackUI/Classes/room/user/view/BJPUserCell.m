//
//  BJPUserCell.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/7/2.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPUserCell.h"
#import "BJPAppearance.h"

#import <BJLiveBase/BJL_EXTScope.h>
#import <BJLiveBase/BJLWebImage.h>

static const CGFloat avatarSize = 32.0;

@interface BJPUserCell ()

@property (nonatomic) UIImageView *avatarView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *roleLabel;

@end

@implementation BJPUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentView];
    }
    return self;
}

#pragma mark - content view

- (void)setupContentView {
    // 头像
    [self.contentView addSubview:self.avatarView];
    [self.avatarView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(BJPViewSpaceL);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(avatarSize));
    }];
    
    // 昵称
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.avatarView.bjl_right).offset(BJPViewSpaceM);
        make.right.lessThanOrEqualTo(self.contentView).offset(-BJPViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
    
    // 角色
    [self.contentView addSubview:self.roleLabel];
    [self.roleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.bjl_right).offset(BJPViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.size.equal.sizeOffset(CGSizeMake(32.0, 16.0));
    }];
}

#pragma mark - public

- (void)updateWithUser:(BJVUser *)user {
    // 头像
    [self.avatarView bjl_setImageWithURL:[NSURL URLWithString:user.avatar]
                             placeholder:[UIImage bjp_imageNamed:@"bjp_ic_avatar"]
                              completion:nil];
    
    // 昵称
    self.nameLabel.text = user.displayName;
    
    // 角色
    self.roleLabel.hidden = !user.isTeacherOrAssistant;
    self.roleLabel.text = user.isTeacher ? @"老师" : user.isAssistant ? @"助教" : nil;
}

#pragma mark - getters

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.backgroundColor = [UIColor bjp_grayImagePlaceholderColor];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = avatarSize / 2.0;
            imageView;
        });
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor bjp_darkGrayTextColor];
            label.font = [UIFont systemFontOfSize:15.0];
            label;
        });
    }
    return _nameLabel;
}

- (UILabel *)roleLabel {
    if (!_roleLabel) {
        _roleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor bjp_blueBrandColor];
            label.font = [UIFont systemFontOfSize:11.0];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = BJPButtonCornerRadius;
            label.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
            label.layer.borderColor = [UIColor bjp_blueBrandColor].CGColor;
            label;
        });
    }
    return _roleLabel;
}

@end
