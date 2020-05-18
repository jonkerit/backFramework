//
//  BJPControlView.h
//  BJLiveBase
//
//  Created by xijia dai on 2019/12/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLiveBase.h>
#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPControlView : BJLHitTestView

@property (nonatomic, nullable, readonly) UIButton *messageButton, *thumbnailButton, *usersButton, *questionButton;
@property (nonatomic, nullable, readonly) UILabel *questionRedDot;
@property (nonatomic, nullable) void (^showMessageCallback)(BOOL show);
@property (nonatomic, nullable) void (^showThumbnailCallback)(void);
@property (nonatomic, nullable) void (^showUsersCallback)(void);
@property (nonatomic, nullable) void (^showQuestionCallback)(void);

- (instancetype)initWithRoom:(BJVRoom *)room;
- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal;

@end

NS_ASSUME_NONNULL_END
