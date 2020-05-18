//
//  BJPUserCell.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/7/2.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPUserCell : UITableViewCell

- (void)updateWithUser:(BJVUser *)user;

@end

NS_ASSUME_NONNULL_END
