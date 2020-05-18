//
//  BJPQuestionViewController.h
//  BJPlaybackUI
//
//  Created by xijia dai on 2019/12/5.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BJVRoom;

@interface BJPQuestionViewController : BJLTableViewController

@property (nonatomic, nullable) void (^showRedDotCallback)(BOOL show);
@property (nonatomic, nullable) void (^hideCallback)(void);

- (instancetype)initWithRoom:(BJVRoom *)room;

@end

NS_ASSUME_NONNULL_END
