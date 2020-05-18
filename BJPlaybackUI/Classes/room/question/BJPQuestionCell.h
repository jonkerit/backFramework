//
//  BJPQuestionCell.h
//  BJPlaybackUI
//
//  Created by xijia dai on 2019/12/5.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString
* const BJPQuestionCellReuseIdentifier,
* const BJPQuestionReplyCellReuseIdentifier;

@class BJLQuestion;

@interface BJPQuestionCell : UITableViewCell

@property (nonatomic, nullable) void (^singleTapCallback)(void);

@property (nonatomic, nullable) void (^longPressCallback)(NSString *content);

- (void)updateWithQuestion:(nullable BJLQuestion *)question questionReply:(nullable BJLQuestionReply *)questionReply;

+ (NSArray<NSString *> *)allCellIdentifiers;

@end

NS_ASSUME_NONNULL_END

