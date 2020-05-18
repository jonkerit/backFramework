//
//  BJPReloadingView.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/26.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPReloadView : UIView

@property (nonatomic, copy, nullable) void (^reloadCallback)(void);

- (void)showWithTitle:(NSString *)title detail:(NSString *)detail;

@end

NS_ASSUME_NONNULL_END
