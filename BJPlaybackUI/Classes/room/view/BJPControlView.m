//
//  BJPControlView.m
//  BJLiveBase
//
//  Created by xijia dai on 2019/12/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJPControlView.h"
#import "BJPAppearance.h"

@interface BJPControlView ()

@property (nonatomic, weak) BJVRoom *room;
@property (nonatomic) NSMutableArray<UIButton *> *rightButtons, *bottomButtons;
@property (nonatomic, nullable, readwrite) UIButton *messageButton, *thumbnailButton, *usersButton, *questionButton;
@property (nonatomic, nullable, readwrite) UILabel *questionRedDot;

@end

@implementation BJPControlView

- (instancetype)initWithRoom:(BJVRoom *)room {
    if (self = [super initWithFrame:CGRectZero]) {
        self.room = room;
        [self makeSubviewAndConstraints];
    }
    return self;
}

- (void)makeSubviewAndConstraints {
    self.usersButton = [self makeButtonWithImage:[UIImage bjp_imageNamed:@"bjp_ic_users"]
                                   selectedImage:nil
                                          action:@selector(showUsersView:)
                              accessibilityLabel:BJLKeypath(self, usersButton)];
    self.thumbnailButton = [self makeButtonWithImage:[UIImage bjp_imageNamed:@"bjlchange"]
                                       selectedImage:[UIImage bjp_imageNamed:@"bjlShowLitterScreen"]
                                              action:@selector(showThumbnailView:)
                                  accessibilityLabel:BJLKeypath(self, thumbnailButton)];
//    self.thumbnailButton.hidden = YES;
    self.messageButton = [self makeButtonWithImage:[UIImage bjp_imageNamed:@"bjlCloseInfo"]
                                     selectedImage:[UIImage bjp_imageNamed:@"bjlShowInfo"]
                                            action:@selector(showMessageView:)
                                accessibilityLabel:BJLKeypath(self, messageButton)];
    self.questionButton = [self makeButtonWithImage:[UIImage bjp_imageNamed:@"bjp_ic_question"]
                                       selectedImage:nil
                                              action:@selector(showQuestionView:)
                                 accessibilityLabel:BJLKeypath(self, questionButton)];
    
    self.rightButtons = [@[self.messageButton, self.thumbnailButton] mutableCopy];
    self.bottomButtons = [@[] mutableCopy];
    if (self.room.playbackInfo.enableQuestion) {
        [self.bottomButtons bjl_addObject:self.questionButton];
    }
//    BOOL isHorizontal = BJPIsHorizontalUI(self);
    // ios12, BJPIsHorizontalUI 判断方向会出错
    BOOL isHorizontal = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    [self remakeRightConstraints:isHorizontal];
    [self remakeBottomConstraints:isHorizontal];
    
    self.questionRedDot = [self makeRedDot];
    [self.questionButton addSubview:self.questionRedDot];
    [self.questionRedDot bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.right.top.equalTo(self.questionButton);
        make.width.height.equalTo(@10.0);
    }];
}

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    [self remakeRightConstraints:isHorizontal];
    [self remakeBottomConstraints:isHorizontal];
}

#pragma mark - callback

- (void)showMessageView:(UIButton *)button {
    button.selected = !button.isSelected;
    if (self.showMessageCallback) {
        self.showMessageCallback(!button.isSelected);
    }
}

- (void)showThumbnailView:(UIButton *)button {
    button.selected = NO;
    if (self.showThumbnailCallback) {
        self.showThumbnailCallback();
    }
}

- (void)showUsersView:(UIButton *)button {
    if (self.showUsersCallback) {
        self.showUsersCallback();
    }
}

- (void)showQuestionView:(UIButton *)button {
    if (self.showQuestionCallback) {
        self.showQuestionCallback();
    }
}

#pragma mark - wheel

- (void)remakeRightConstraints:(BOOL)isHorizontal {
    isHorizontal = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES : isHorizontal;
    UIButton *last = nil;
    for (UIButton *button in self.rightButtons) {
        [button bjl_remakeConstraints:^(BJLConstraintMaker * _Nonnull make) {
            if (!last) {
                make.width.height.equalTo(@(BJPButtonSizeM)).priorityHigh();
                make.right.equalTo(self).offset(-BJPViewSpaceM);
                make.bottom.equalTo(self).offset(isHorizontal ? -BJPButtonSizeL - BJPViewSpaceM : -BJPViewSpaceM);
            }
            else {
                make.left.right.height.equalTo(last);
                make.bottom.equalTo(last.bjl_top).offset(-BJPViewSpaceM);
            }
        }];
        last = button;
    }
}

- (void)remakeBottomConstraints:(BOOL)isHorizontal {
    isHorizontal = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES : isHorizontal;
    UIButton *last = nil;
    for (UIButton *button in self.bottomButtons) {
        [button bjl_remakeConstraints:^(BJLConstraintMaker * _Nonnull make) {
            if (!last) {
                make.left.equalTo(self).offset(BJPViewSpaceM);
                make.bottom.equalTo(self).offset(isHorizontal ? -BJPButtonSizeL - BJPViewSpaceM : -BJPViewSpaceM);
                make.width.height.equalTo(@(BJPButtonSizeM));
            }
            else {
                make.top.bottom.width.equalTo(last);
                make.left.equalTo(last.bjl_right).offset(BJPViewSpaceM);
            }
        }];
        last = button;
    }
}

- (UIButton *)makeButtonWithImage:(nullable UIImage *)image
                    selectedImage:(nullable UIImage *)selectedImage
                           action:(nullable SEL)selector
               accessibilityLabel:(NSString *)accessibilityLabel {
    UIButton *button = [UIButton new];
    button.accessibilityLabel = accessibilityLabel;
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    if (selectedImage) {
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (UILabel *)makeRedDot {
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor redColor];
    label.hidden = YES;
    label.layer.cornerRadius = 5.0;
    label.layer.masksToBounds = YES;
    return label;
}

@end
