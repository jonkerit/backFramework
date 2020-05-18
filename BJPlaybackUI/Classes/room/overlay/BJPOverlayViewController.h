//
//  BJPOverlayViewController.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/7/2.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BJPOverlayViewController : UIViewController

- (void)showWithChildViewController:(UIViewController *)childViewController title:(NSString *)title;

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal;

@end
