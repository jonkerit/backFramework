//
//  BJPSliderView.m
//  BJPlaybackUI
//
//  Created by daixijia on 2018/3/9.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BJVideoPlayerCore/BJVPlayerMacro.h>
#import <BJLiveBase/BJLProgressHUD.h>

#import "BJPSliderView.h"
#import "BJPAppearance.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJPSliderType) {
    BJPSliderType_None,
    BJPSliderType_Slide,
    BJPSliderType_Volume,
    BJPSliderType_Light
};

@interface BJPSliderView ()

@property (strong, nonatomic) BJPSliderSeekView *seekView;
@property (strong, nonatomic) BJPSliderLightView *lightView;
@property (strong, nonatomic) MPVolumeView *volumeView;

@property (assign, nonatomic) CGFloat beginValue;
@property (assign, nonatomic) CGFloat durationValue;
@property (assign, nonatomic) CGFloat originVolume;
@property (assign, nonatomic) CGFloat originBrightness;
@property (assign, nonatomic) CGFloat seekTargetTime; // 用于快速 seek 过程中记录中间值，延时回调

@property (assign, nonatomic) CGPoint touchBeganPoint;
@property (assign, nonatomic) BJPSliderType touchMoveType;
@end

@implementation BJPSliderView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.seekView];
        [self.seekView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.center.equal.to(@0);
            make.size.equal.sizeOffset(CGSizeMake(150, 80));
        }];
        
        self.slideEnabled = YES;
        self.seekTargetTime = - 1.0;
    }
    return self;
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        self.touchBeganPoint = [touch locationInView:self];
        self.touchMoveType = BJPSliderType_None;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) { //单指滑动
        CGPoint movePoint = [[touches anyObject] locationInView:self];
        [self updateTouchMoveTypeByPoint:movePoint];
        
        CGFloat diffX = movePoint.x - self.touchBeganPoint.x;
        CGFloat diffY = movePoint.y - self.touchBeganPoint.y;
        if (self.touchMoveType == BJPSliderType_Slide) {
            [self.seekView resetRelTime:_beginValue duration:_durationValue difference:diffX/10];
            self.seekView.hidden = NO;
        }
        else if (self.touchMoveType == BJPSliderType_Light) {
            CGFloat brightness = self.originBrightness-diffY/100;
            if (brightness >= 1.0) {
                brightness = 1.0;
            }
            else if (brightness <= 0.0) {
                brightness = 0;
            }
            [[UIScreen mainScreen] setBrightness:brightness];
        }
        else if (self.touchMoveType == BJPSliderType_Volume) {
            CGFloat value = self.originBrightness-diffY/100;
            if (value >= 1.0) {
                value = 1.0;
            }
            else if (value <= 0.0) {
                value = 0;
            }
            [self volumeSlider].value = value;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) { //单指滑动
        UITouch *touch = [touches anyObject];
        CGPoint movePoint = [touch locationInView:self];
        CGFloat diff = movePoint.x - self.touchBeganPoint.x;
        if (fabs(diff/10) > 5 && self.touchMoveType == BJPSliderType_Slide) { //大于5秒
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(seekAction) object:nil];
            CGFloat curr = [self modifyValue:self.beginValue + diff/10 minValue:0 maxValue:self.durationValue];
            self.seekTargetTime = curr;
            [self performSelector:@selector(seekAction) withObject:nil afterDelay:0.5];
        }
        else {
            self.seekView.hidden = YES;
        }
    }
    [UIView animateWithDuration:3 animations:^{
        self.lightView.alpha = 0.0f;
    }];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [BJLMBProgressHUD hideHUDForView:keyWindow animated:YES];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    self.seekView.hidden = YES;
    [UIView animateWithDuration:3 animations:^{
        self.lightView.alpha = 0.0f;
    }];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [BJLMBProgressHUD hideHUDForView:keyWindow animated:YES];
}

#pragma mark - action

- (void)seekAction {
    if ([self.delegate respondsToSelector:@selector(touchSlideView:finishHorizonalSlide:)]) {
        [self.delegate touchSlideView:self finishHorizonalSlide:self.seekTargetTime];
    }
    // 重置中间值, 隐藏 seek 视图
    self.seekTargetTime = -1.0;
    self.seekView.hidden = YES;
}

#pragma mark touch private

- (void)updateTouchMoveTypeByPoint:(CGPoint)movePoint {
    CGFloat diffX = movePoint.x - self.touchBeganPoint.x;
    CGFloat diffY = movePoint.y - self.touchBeganPoint.y;
    if ((fabs(diffX) > 20 || fabs(diffY) > 20) && self.touchMoveType == BJPSliderType_None) {
        if (fabs(diffX/diffY) > 1.7) {
            self.touchMoveType = BJPSliderType_Slide;
            self.beginValue = self.seekTargetTime >= 0 ? self.seekTargetTime : [self.delegate originValueForTouchSlideView:self];
            self.durationValue = [self.delegate durationValueForTouchSlideView:self];
        }
        else if (fabs(diffX/diffY) < 0.6) {
            if (self.touchBeganPoint.x < (self.bounds.size.width / 2)) { //调亮度
                self.touchMoveType = BJPSliderType_Light;
                self.originBrightness = [UIScreen mainScreen].brightness;
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                self.lightView.alpha = 1.0f;
                [keyWindow insertSubview:self.lightView aboveSubview:self];
                [self.lightView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
                    make.height.width.equalTo(@155);
                    make.centerY.centerX.equalTo(keyWindow);
                }];
            }
            else {
                self.touchMoveType = BJPSliderType_Volume;
                self.originVolume = [self volumeSlider].value;
            }
        }
    }
}

- (CGFloat)modifyValue:(double)value minValue:(double)min maxValue:(double)max {
    value = value < min ? min : value;
    value = value > max ? max : value;
    
    return value;
}

#pragma mark - set get

- (BJPSliderSeekView *)seekView {
    if (!_seekView) {
        _seekView = [[BJPSliderSeekView alloc] init];
        _seekView.layer.cornerRadius = 10.f;
        _seekView.hidden = YES;
    }
    return _seekView;
}

- (BJPSliderLightView *)lightView {
    if (!_lightView) {
        _lightView = [[BJPSliderLightView alloc] init];
    }
    return _lightView;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
    }
    return _volumeView;
}

- (nullable UISlider *)volumeSlider {
    for (UIView *newView in self.volumeView.subviews) {
        if ([newView isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)newView;
            slider.hidden = YES;
            slider.autoresizesSubviews = NO;
            slider.autoresizingMask = UIViewAutoresizingNone;
            return (UISlider *)slider;
        }
    }
    return nil;
}

@end

@interface BJPSliderLightView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *lightView;
@property (strong, nonatomic) UIImageView *progressView;
@property (strong, nonatomic) UIView *coverView;

@end

@implementation BJPSliderLightView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 155, 155)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self addObservers];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return self.bounds.size;
}

- (void)setupSubviews {
    self.layer.cornerRadius  = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor grayColor];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.backgroundColor = [UIColor darkGrayColor];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    [self addSubview:self.titleLabel];
    [self addSubview:self.lightView];
    [self addSubview:self.progressView];
    [self.progressView addSubview:self.coverView];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equal.to(@0);
        make.height.equalTo(@30);
        make.top.equal.to(@5);
        make.width.equalTo(self);
    }];
    [self.lightView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.centerY.equal.to(@0);
        make.height.width.equalTo(@70);
    }];
    [self.progressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equal.to(@0);
        //        make.top.equalTo(self.lightView.bjl_bottom).offset(10.f);
        make.bottom.equal.to(@-15.f);
        make.height.equalTo(@7);
        make.left.equal.to(@13.f);
    }];
}

#pragma mark - kvo

- (void)addObservers {
    UIScreen *screen = [UIScreen mainScreen];
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(screen, brightness) observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
        bjl_strongify(self);
        CGFloat brightness = MAX(0.0, MIN(1.0, screen.brightness));
        [self.coverView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.top.bottom.right.equal.to(@0);
            make.width.equalTo(self.progressView.bjl_width).multipliedBy(1.0 - brightness);
        }];
        return YES;
    }];
}

#pragma mark - set get

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _titleLabel.text = @"亮度";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)lightView {
    if (!_lightView) {
        _lightView = [[UIImageView alloc] init];
        _lightView.image = [UIImage bjp_imageNamed:@"bjp_ic_sun"];
    }
    return _lightView;
}

- (UIImageView *)progressView {
    if (!_progressView) {
        _progressView = [[UIImageView alloc] init];
        _progressView.image = [UIImage bjp_imageNamed:@"bjp_ic_light"];
    }
    return _progressView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor bjp_darkGrayTextColor];
    }
    return _coverView;
}

@end


@interface BJPSliderSeekView ()

@property (strong, nonatomic) UIImageView *directImageView;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation BJPSliderSeekView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
        [self addSubview:self.directImageView];
        [self addSubview:self.timeLabel];
        
        [self.directImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equal.to(@0);
            make.centerY.equal.to(@(-10));
        }];
        [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equal.to(@0);
            make.top.equalTo(self.directImageView.bjl_bottom).offset(5.f);
        }];
    }
    return self;
}

#pragma mark - public

- (void)resetRelTime:(long)relTime duration:(long)duration difference:(long)difference {
    if (difference > 0) {
        self.directImageView.image = [UIImage bjp_imageNamed:@"bjp_ic_forward"];
    }
    else {
        self.directImageView.image = [UIImage bjp_imageNamed:@"bjp_ic_backward"];
    }
    
    long seekTime = relTime + difference;
    seekTime = seekTime > 0 ? seekTime : 0;
    seekTime = seekTime < duration ? seekTime : duration;
    
    long seekHours = seekTime / 3600;
    int seekMinums = ((long long)seekTime % 3600) / 60;
    int seekSeconds = (long long)seekTime % 60;
    
    long totalHours = duration / 3600;
    int totalMinums = ((long long)duration % 3600) / 60;
    int totalSeconds = (long long)duration % 60;
    if (totalHours > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02d:%02d / %02ld:%02d:%02d",
                               seekHours, seekMinums, seekSeconds, totalHours, totalMinums, totalSeconds];
    }
    else {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d",
                               seekMinums, seekSeconds, totalMinums, totalSeconds];
    }
}

#pragma mark - set get

- (UIImageView *)directImageView {
    if (!_directImageView) {
        _directImageView = [[UIImageView alloc] init];
    }
    return _directImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

@end

NS_ASSUME_NONNULL_END
