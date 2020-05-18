//
//  BJPProgressView.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPProgressView.h"
#import "BJPAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPProgressView()

@property (nonatomic, readwrite, nullable) BJPlayerSlider *slider;
@property (nonatomic, nullable) UIView *sliderBgView;
@property (nonatomic, nullable) UIView *cacheView;
@property (nonatomic, nullable) UIImageView *progressView;
@property (nonatomic, nullable) UIImageView *durationView;

@end

@implementation BJPProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self makeConstraints];
        [self setValue:0 cache:0 duration:0];
    }
    return self;
}

- (void)dealloc {
    self.sliderBgView = nil;
    self.slider = nil;
    self.cacheView = nil;
    self.progressView = nil;
}

- (void)setupViews {
    self.sliderBgView = [[UIView alloc] init];
    self.sliderBgView.layer.masksToBounds = YES;
    self.sliderBgView.layer.cornerRadius = self.sliderBgView.frame.size.height / 2.0;
    
    self.slider = [[BJPlayerSlider alloc] init];
//    self.slider.touchToChanged = NO;
    self.slider.backgroundColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    
    UIImage *leftStretch = [[UIImage bjp_imageNamed:@"bjp_ic_player_progress_orange.png"]
                            stretchableImageWithLeftCapWidth:4.0
                            topCapHeight:1.0];
    UIImage *rightStretch = [[UIImage bjp_imageNamed:@"bjp_ic_player_progress_gray.png"]
                             stretchableImageWithLeftCapWidth:4.0
                             topCapHeight:1.0];
    
    // iOS 8 以下用自定义的
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0)
    {
        [self.slider setMinimumTrackImage:leftStretch forState:UIControlStateNormal];
    }
//        [self.slider setMaximumTrackImage:rightStretch forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage bjp_imageNamed:@"bjp_ic_player_current.png"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage bjp_imageNamed:@"bjp_ic_player_current_big.png"] forState:UIControlStateHighlighted];
    
    self.cacheView = [[UIView alloc] init];
    
    self.cacheView.layer.masksToBounds = YES;
    self.cacheView.layer.cornerRadius = 1;
    self.cacheView.backgroundColor = [UIColor whiteColor];
    
    self.progressView = [[UIImageView alloc] init];
    
    self.progressView.layer.masksToBounds = YES;
    self.progressView.image = leftStretch;
    
    self.durationView = [[UIImageView alloc] init];
    
    self.durationView.layer.cornerRadius = 1;
    self.durationView.layer.masksToBounds = YES;
    self.durationView.image = rightStretch;
    
    [self.sliderBgView addSubview:self.durationView];
    [self.sliderBgView addSubview:self.cacheView];
    [self.sliderBgView addSubview:self.progressView];
    
    [self addSubview:self.sliderBgView];
    [self addSubview:self.slider];
}

- (void)makeConstraints {
    [self.sliderBgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.centerY.equalTo(self);
        make.height.equalTo(@2.0);
    }];
    
    [self.durationView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.sliderBgView).offset(2.0);
        make.top.bottom.equalTo(self.sliderBgView);
        make.width.equalTo(self.sliderBgView);
    }];
    
    [self.slider bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self).offset(2.0);
        make.centerY.equalTo(self).offset(-1.0);
        make.height.width.equalTo(self);
    }];
    
    [self.cacheView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.equalTo(self.sliderBgView);
        make.left.equalTo(self.sliderBgView).offset(2.0);
        make.width.equalTo(@0.0);
    }];
    
    [self.progressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.sliderBgView);
        make.width.equalTo(@0.0);
    }];
}

- (void)setValue:(float)value cache:(float)cache duration:(float)duration {
    CGFloat progressWidth = CGRectGetWidth(self.frame) - 2.0;
    self.slider.maximumValue = duration;
    self.slider.value = value;
    if (duration) {
        CGFloat progressF = value / duration;
        CGFloat cacheF = cache / duration;
        [self.progressView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(@(progressWidth * progressF));
        }];
        [self.cacheView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(@(progressWidth * cacheF));
        }];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end

#pragma mark -

@interface BJPlayerSlider ()
//关于点击就可以更新进度条的实现
//@property (nonatomic, assign) BOOL touchToChanged;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BJPlayerSlider
//- (void)setTouchToChanged:(BOOL)touchToChanged
//{
//    _touchToChanged = touchToChanged;
//    self.tapGestureRecognizer.enabled = touchToChanged;
//}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumbRect.origin.x = (self.maximumValue > 0 ? (value / self.maximumValue * self.frame.size.width):0) - self.currentThumbImage.size.width / 2;
    thumbRect.origin.y = 0;
    thumbRect.size.height = bounds.size.height;

    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

//关于点击就可以更新进度条的实现
//- (void)tapAction:(UITapGestureRecognizer *)tapGesture
//{
//    if (self.touchToChanged) {
//        CGPoint point = [tapGesture locationInView:tapGesture.view];
//        CGFloat percentage = point.x/self.frame.size.width;
//        self.value = ceil(MIN(percentage,1)*self.maximumValue);
//        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
//    }
//}
//
//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
//    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
//    self.tapGestureRecognizer.enabled = (!begin && self.touchToChanged);
//    return begin;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
//    return [super continueTrackingWithTouch:touch withEvent:event];
//}
//
//- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
//    [super endTrackingWithTouch:touch withEvent:event];
//    self.tapGestureRecognizer.enabled = (YES && self.touchToChanged);
//}
//
//- (void)cancelTrackingWithEvent:(nullable UIEvent *)event {
//    [super cancelTrackingWithEvent:event];
//}
//
//#pragma mark - get
//- (UITapGestureRecognizer *)tapGestureRecognizer
//{
//    if (!_tapGestureRecognizer) {
//        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//        [self addGestureRecognizer:_tapGestureRecognizer];
//    }
//    return _tapGestureRecognizer;
//}

@end

NS_ASSUME_NONNULL_END
