//
//  BJPPlaybackControlView.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPPlaybackControlView : UIView

#pragma mark - slider

@property (nonatomic, readonly) BOOL slideCanceled;
@property (nonatomic, readonly) BOOL controlsHidden;

- (void)setSlideEnable:(BOOL)enable;

#pragma mark - update

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal;

- (void)updateContentWithCurrentTime:(NSTimeInterval)currentTime
                       cacheDuration:(NSTimeInterval)cacheDuration
                       totalDuration:(NSTimeInterval)totalDuration;

- (void)updateWithPlayState:(BOOL)playing;

- (void)updateWithRate:(NSString *)rateString;

- (void)updateWithDefinition:(NSString *)definitionString;

- (void)showReloadViewWithTitle:(NSString *)title detail:(NSString *)detail;
- (void)hideReloadView;

- (void)updateViewForInteractiveClass;

#pragma mark - call backs

@property (nonatomic, copy, nullable) void (^cancelCallback)(void);
@property (nonatomic, copy, nullable) void (^mediaPlayCallback)(void);
@property (nonatomic, copy, nullable) void (^mediaPauseCallback)(void);
@property (nonatomic, copy, nullable) void (^mediaSeekCallback)(NSTimeInterval toTime);
@property (nonatomic, copy, nullable) void (^showRateListCallback)(void);
@property (nonatomic, copy, nullable) void (^showDefinitionListCallback)(void);
@property (nonatomic, copy, nullable) void (^rotateCallback)(BOOL horizontal);
@property (nonatomic, copy, nullable) void (^reloadCallback)(void);
@property (nonatomic, copy, nullable) void (^doubleTapCallback)(void);

@end

NS_ASSUME_NONNULL_END
