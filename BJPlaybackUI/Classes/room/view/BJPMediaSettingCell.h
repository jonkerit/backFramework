//
//  BJPMediaSettingCell.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/14.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPMediaSettingCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^selectCallback)(void);

- (void)updateWithSettingTitle:(NSString *)title selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
