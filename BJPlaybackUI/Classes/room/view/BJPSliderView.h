//
//  BJPSliderView.h
//  BJPlaybackUI
//
//  Created by daixijia on 2018/3/9.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BJPSliderView;

@protocol BJPSliderProtocol <NSObject>

@optional
- (CGFloat)originValueForTouchSlideView:(BJPSliderView *)touchSlideView;
- (CGFloat)durationValueForTouchSlideView:(BJPSliderView *)touchSlideView;
- (void)touchSlideView:(BJPSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value;

@end

@interface BJPSliderView : UIView

@property (weak, nonatomic) id<BJPSliderProtocol> delegate;
@property (nonatomic, assign) BOOL slideEnabled;

@end

@interface BJPSliderLightView : UIView

@end

@interface BJPSliderSeekView : UIView

- (void)resetRelTime:(long)relTime duration:(long)duration difference:(long)difference;

@end

NS_ASSUME_NONNULL_END
