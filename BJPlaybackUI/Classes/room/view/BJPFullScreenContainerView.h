//
//  BJPFullScreenContainerView.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPFullScreenContainerView : UIView

- (void)replaceContentWithPPTView:(UIView *)pptView;

- (void)replaceContentWithPlayerView:(UIView *)playerView ratio:(CGFloat)ratio;

@end

NS_ASSUME_NONNULL_END
