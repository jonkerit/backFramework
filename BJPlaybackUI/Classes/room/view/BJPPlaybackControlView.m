//
//  BJPPlaybackControlView.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPPlaybackControlView.h"
#import "BJPProgressView.h"
#import "BJPSliderView.h"
#import "BJPReloadView.h"
#import "BJPAppearance.h"

#import <BJLiveBase/BJL_EXTScope.h>

@interface BJPPlaybackControlView () <BJPSliderProtocol>

@property (nonatomic) UIImageView *topBarView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIView *mediaControlView;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *rateButton;
@property (nonatomic) UIButton *definitionButton;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) BJPProgressView *progressView;
@property (nonatomic) BJPSliderView *sliderView;
@property (nonatomic) BJPReloadView *reloadView;

@property (nonatomic, readwrite) BOOL slideCanceled;
@property (nonatomic, readwrite) BOOL controlsHidden;
@property (nonatomic) BOOL stopUpdateProgress;
@property (nonatomic) BOOL isHorizontal;

@property (nonatomic) BOOL shouldHiddenControlsForinteractive;

@end

@implementation BJPPlaybackControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.slideCanceled = YES;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subViews

- (void)setupSubviews {
    // slider view
    [self addSubview:self.sliderView];
    [self.sliderView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.bjl_safeAreaLayoutGuide ?: self);
    }];
    
    // topBar
    CGFloat statusBarHeight = MAX(20.0, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    [self addSubview:self.topBarView];
    [self.topBarView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(statusBarHeight));
    }];
    
    // media control view
    [self addSubview:self.mediaControlView];
    [self.mediaControlView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.bjl_safeAreaLayoutGuide ?: self);
        make.height.equalTo(@(BJPButtonSizeL));
    }];
    [self setupMediaControlView];
    
    // reload view
    [self addSubview:self.reloadView];
    [self.reloadView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // cancel button
    [self addSubview:self.cancelButton];
    [self.cancelButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.topBarView.bjl_bottom).offset(BJPViewSpaceS);
        make.right.equalTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-BJPViewSpaceS);
        make.size.equal.sizeOffset(CGSizeMake(30.0, 30.0));
    }];
}

- (void)setupMediaControlView {
    CGFloat margin = 15.0;
    UIView *controlView = self.mediaControlView;
    
    // 播放/暂停 按钮
    [controlView addSubview:self.playButton];
    [self.playButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(controlView).offset(margin);
        make.top.bottom.equalTo(controlView);
        make.width.equalTo(@35.0);
    }];
    
    // 屏幕旋转按钮
    [controlView addSubview:self.rotateButton];
    [self.rotateButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        // iPad 不显示旋屏按钮
        make.width.equalTo(isIpad ? @0.0 : @35.0);
        make.right.equalTo(controlView).offset(-margin);
        make.centerY.equalTo(controlView);
        
    }];
    
    // 倍速按钮
    [controlView addSubview:self.rateButton];
    [self.rateButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.equalTo(controlView);
        make.right.equalTo(self.rotateButton.bjl_left).offset(-margin);
        make.width.equalTo(@35.0);
    }];
    
    // 清晰度按钮
    [controlView addSubview:self.definitionButton];
    [self.definitionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.equalTo(controlView);
        make.right.equalTo(self.rateButton.bjl_left).offset(-margin);
        make.width.equalTo(@40.0);
    }];
    
    // 播放时间 label, 约束视横竖屏而定
    [controlView addSubview:self.timeLabel];
    
    // 播放进度条, 约束视横竖屏而定
    [controlView addSubview:self.progressView];
}

#pragma mark - constraints

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    self.isHorizontal = isHorizontal;
    self.timeLabel.textAlignment = isHorizontal ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    self.rotateButton.selected = isHorizontal;
    
    // 旋转时显示相关控件
    [self setControlsHidden:NO];
    
    // constraints
    if (isHorizontal) {
        [self.timeLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.playButton.bjl_right).offset(15.0);
            make.right.equalTo(self.playButton).offset(90.0);
            make.top.bottom.equalTo(self.mediaControlView);
        }];

        [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.timeLabel.bjl_right).offset(15.0).priorityHigh();
            make.right.equalTo(self.definitionButton.bjl_left).offset(-20.0);
            make.height.centerY.equalTo(self.mediaControlView);
        }];
    }
    else {
        [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.playButton.bjl_right).offset(15.0).priorityHigh();
            make.right.equalTo(self.definitionButton.bjl_left).offset(-20.0);
            make.height.centerY.equalTo(self.mediaControlView);
        }];
        
        [self.timeLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.progressView);
            make.bottom.equalTo(self.mediaControlView);
            make.top.equalTo(self.progressView.bjl_centerY).offset(6.0);
        }];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - public

- (void)updateContentWithCurrentTime:(NSTimeInterval)currentTime
                       cacheDuration:(NSTimeInterval)cacheDuration
                       totalDuration:(NSTimeInterval)totalDuration {
    if (self.stopUpdateProgress) {
        return;
    }
    
    currentTime = MAX(currentTime, 0.0);
    cacheDuration = MAX(cacheDuration, 0.0);
    totalDuration = MAX(totalDuration, 0.0);
    
    NSString *currentTimeString = [self stringWithTimeInterval:currentTime];
    NSString *durationString = [self stringWithTimeInterval:totalDuration];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", currentTimeString, durationString];
    [self.progressView setValue:currentTime cache:cacheDuration duration:totalDuration];
}

- (void)updateWithPlayState:(BOOL)playing {
    self.playButton.selected = playing;
}

- (void)setSlideEnable:(BOOL)enable {
    self.progressView.userInteractionEnabled = enable;
    self.sliderView.slideEnabled = enable;
}

- (void)updateWithRate:(NSString *)rateString {
    [self.rateButton setTitle:rateString ?: @"1.0x" forState:UIControlStateNormal];
}

- (void)updateWithDefinition:(NSString *)definitionString {
    [self.definitionButton setTitle:definitionString ?: @"高清" forState:UIControlStateNormal];
}

- (void)showReloadViewWithTitle:(NSString *)title detail:(NSString *)detail {
    [self.reloadView showWithTitle:title detail:detail];
    self.cancelButton.hidden = NO;
    bjl_weakify(self);
    [self.reloadView setReloadCallback:^{
        bjl_strongify(self);
        if (self.reloadCallback) {
            self.reloadCallback();
        }
        [self setControlsHidden:NO];
    }];
}

- (void)hideReloadView {
    self.reloadView.hidden = YES;
}

- (void)updateViewForInteractiveClass {
    
    self.shouldHiddenControlsForinteractive = YES;
    
    CGFloat margin = 15.0;
    // 屏幕旋转按钮
    [self.rotateButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(@0.0);
    }];
    
    // 倍速按钮
    [self.rateButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.mediaControlView).offset(-margin);
    }];
    
    [self.cancelButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-margin);
    }];

    [self updateConstraintsForHorizontal:YES];
}

#pragma mark - actions

- (void)cancel {
    if (self.cancelCallback) {
        self.cancelCallback();
    }
}

- (void)playButtonOnClick:(UIButton *)button {
    if (button.selected) {
        [self pause];
    }
    else {
        [self play];
    }
}

- (void)play {
    if (self.mediaPlayCallback) {
        self.mediaPlayCallback();
        [self disablePlayControlsAndThenRecover];
    }
}

- (void)pause {
    if (self.mediaPauseCallback) {
        self.mediaPauseCallback();
        [self disablePlayControlsAndThenRecover];
    }
}

- (void)seekToTime:(NSTimeInterval)time {
    if (self.mediaSeekCallback) {
        self.mediaSeekCallback(time);
    }
}

- (void)showRateList {
    if (self.showRateListCallback) {
        self.showRateListCallback();
    }
}

- (void)showDefinitionList {
    if (self.showDefinitionListCallback) {
        self.showDefinitionListCallback();
    }
}

- (void)rotateButtonOnClick:(UIButton *)button {
    BOOL horizontal = !button.selected;
    button.selected = horizontal;
    if (self.rotateCallback) {
        self.rotateCallback(horizontal);
    }
}

- (void)doubleTap {
    if (self.doubleTapCallback) {
        self.doubleTapCallback();
    }
}

#pragma mark - progress view actions

- (void)sliderChanged:(BJPlayerSlider *)slider {
    self.stopUpdateProgress = YES;
    self.slideCanceled = NO;
    if (slider.maximumValue > 0.0) {
        self.timeLabel.text = [self stringWithCurrentTime:slider.value duration:slider.maximumValue];
    }
}

- (void)touchSlider:(BJPlayerSlider *)slider {
    self.stopUpdateProgress = YES;
    self.slideCanceled = NO;
    if (slider.maximumValue > 0.0) {
        self.timeLabel.text = [self stringWithCurrentTime:slider.value duration:slider.maximumValue];
    }
}

- (void)dragSlider:(BJPlayerSlider *)slider {
    self.stopUpdateProgress = NO;
    self.slideCanceled = YES;
    if (self.mediaSeekCallback) {
        self.mediaSeekCallback(slider.value);
    }
}

#pragma mark - BJPUSliderProtocol

- (CGFloat)originValueForTouchSlideView:(BJPSliderView *)touchSlideView {
    return self.progressView.slider.value;
}

- (CGFloat)durationValueForTouchSlideView:(BJPSliderView *)touchSlideView {
    return self.progressView.slider.maximumValue;
}

- (void)touchSlideView:(BJPSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value {
    [self seekToTime:value];
}

#pragma mark - show & hide controls

- (void)showOrHideControls {
    if (!self.isHorizontal) {
        // 竖屏不处理点击隐藏
        return;
    }
    
    self.controlsHidden = !self.mediaControlView.hidden;
}

- (void)setControlsHidden:(BOOL)hidden {
    _controlsHidden = hidden;
    self.mediaControlView.hidden = hidden;
    self.cancelButton.hidden = hidden;
    self.topBarView.hidden = hidden;
}

#pragma mark - private

- (NSString *)stringWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    NSString *currentTimeString = [self stringWithTimeInterval:currentTime];
    NSString *durationString = [self stringWithTimeInterval:duration];
    return [NSString stringWithFormat:@"%@ / %@", currentTimeString, durationString];
}

- (NSString *)stringWithTimeInterval:(NSTimeInterval)timeInterval {
    //    3753 == 1:02:33   33 + 120 + 3600
    int hours = timeInterval / 3600;
    int minums = ((long long)timeInterval % 3600) / 60;
    int seconds = (long long)timeInterval % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minums, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d", minums, seconds];
    }
}

- (void)disablePlayControlsAndThenRecover {
    [self setPlayControlButtonsEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setPlayControlButtonsEnabled:YES];
    });
}

- (void)setPlayControlButtonsEnabled:(BOOL)enabled {
    self.playButton.enabled = enabled;
}

#pragma mark - getters

- (UIImageView *)topBarView {
    if (!_topBarView) {
        _topBarView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.image = [UIImage bjp_imageNamed:@"bjp_bg_topbar"];
            [self addSubview:imageView];
            imageView;
        });
    }
    return _topBarView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage bjp_imageNamed:@"bjp_ic_exit"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cancelButton;
}

- (BJPReloadView *)reloadView {
    if (!_reloadView) {
        _reloadView = [[BJPReloadView alloc] init];
    }
    return _reloadView;
}

- (UIView *)mediaControlView {
    if (!_mediaControlView) {
        _mediaControlView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            view.clipsToBounds = YES;
            view;
        });
    }
    return _mediaControlView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage bjp_imageNamed:@"bjp_ic_play"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjp_imageNamed:@"bjp_ic_pause"] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(playButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _playButton;
}

- (UIButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage bjp_imageNamed:@"bjp_ic_ratate_to_full"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjp_imageNamed:@"bjp_ic_ratate_to_small"] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(rotateButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _rotateButton;
}

- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"倍速" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showRateList) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _rateButton;
}

- (UIButton *)definitionButton {
    if (!_definitionButton) {
        _definitionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"清晰度" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showDefinitionList) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _definitionButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"--:-- / --:--";
            label.font = [UIFont systemFontOfSize:9.0];
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor bjp_grayLineColor];
            label;
        });
    }
    return _timeLabel;
}

- (BJPProgressView *)progressView {
    if (!_progressView) {
        _progressView = ({
            BJPProgressView *view = [[BJPProgressView alloc] init];
            [view.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
            [view.slider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventTouchDragInside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpInside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpOutside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchCancel];
            view;
        });
    }
    return _progressView;
}

- (BJPSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = ({
            BJPSliderView *view = [[BJPSliderView alloc] init];
            view.delegate = self;
            view.slideEnabled = YES;
            // 点击事件
            UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideControls)];
            [view addGestureRecognizer:singleTapGesture];
            singleTapGesture.numberOfTapsRequired = 1;
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
            doubleTapGesture.numberOfTapsRequired = 2;
            [view addGestureRecognizer:doubleTapGesture];
            [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
            view;
        });
    }
    return _sliderView;
}

@end
