//
//  BJPAppearance.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/22.
//
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPAppearance.h"
#import "BJPRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN


const CGFloat BJPViewSpaceS = 5.0, BJPViewSpaceM = 10.0, BJPViewSpaceL = 15.0;
const CGFloat BJPControlSize = 44.0;

const CGFloat BJPSmallViewHeight = 76.0, BJPSmallViewWidth = 100.0;

const CGFloat BJPButtonHeight = 30.0, BJPButtonWidth = 105.0;

const CGFloat BJPButtonSizeS = 24.0, BJPButtonSizeM = 36.0, BJPButtonSizeL = 46.0, BJPButtonCornerRadius = 3.0;
const CGFloat BJPBadgeSize = 20.0;
const CGFloat BJPScrollIndicatorSize = 2.5 + 3.0 * 2;

const CGFloat BJPAnimateDurationS = 0.2, BJPAnimateDurationM = BJPAnimateDurationS * 2;
const CGFloat BJPRobotDelayS = 1.0, BJPRobotDelayM = 2.0;

@implementation UIColor (BJPColorLegend)

+ (UIColor *)bjp_darkGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0x1D1D1E];
}

+ (instancetype)bjp_lightGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0xF8F8F8];
}

+ (UIColor *)bjp_darkGrayTextColor {
    return [UIColor bjl_colorWithHex:0x3D3D3E];
}

+ (instancetype)bjp_grayTextColor {
    return [UIColor bjl_colorWithHex:0x6D6D6E];
}

+ (instancetype)bjp_lightGrayTextColor {
    return [UIColor bjl_colorWithHex:0x9D9D9E];
}

+ (instancetype)bjp_grayBorderColor {
    return [UIColor bjl_colorWithHex:0xCDCDCE];
}

+ (instancetype)bjp_grayLineColor {
    return [UIColor bjl_colorWithHex:0xDDDDDE];
}

+ (instancetype)bjp_grayImagePlaceholderColor {
    return [UIColor bjl_colorWithHex:0xEDEDEE];
}

+ (instancetype)bjp_blueBrandColor {
    return [UIColor bjl_colorWithHex:0x37A4F5];
}

+ (instancetype)bjp_orangeBrandColor {
    return [UIColor bjl_colorWithHex:0xFF9100];
}

+ (instancetype)bjp_redColor {
    return [UIColor bjl_colorWithHex:0xFF5850];
}

#pragma mark -

+ (UIColor *)bjp_lightMostDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.2];
}

+ (instancetype)bjp_lightDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.5];
}

+ (instancetype)bjp_dimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.6];
}

+ (instancetype)bjp_darkDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.7];
}

@end

@implementation UIImage (BJPlaybackUI)

+ (UIImage *)bjp_imageNamed:(NSString *)name {
    static NSString * const bundleName = @"BJPlaybackUI", * const bundleType = @"bundle";
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *classBundle = [NSBundle bundleForClass:[BJPRoomViewController class]];
        NSString *bundlePath = [classBundle pathForResource:bundleName ofType:bundleType];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end

@implementation UIImageView (BJPlaybackUI)

- (UIPanGestureRecognizer *)bjp_makePanGestureToHide:(nullable void (^)(void))hideHander customerHander:(nullable void (^)(UIPanGestureRecognizer * _Nullable))customerHander parentView:(UIView *)parentView {
    __block CGPoint originOffsetPoint = CGPointZero;
    __block CGPoint movingTranslation = CGPointZero;
    __block CGFloat originHeight = 0.0;
    __block CGFloat originWidth = 0.0;
    bjl_weakify(self);
    UIPanGestureRecognizer *panGesture = [UIPanGestureRecognizer bjl_gestureWithHandler:^(__kindof UIPanGestureRecognizer * _Nullable gesture) {
        bjl_strongify(self);
        if (customerHander) {
            customerHander(gesture);
        }
        UIView *gestureView = self;
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [gesture setTranslation:CGPointZero inView:parentView];
            originHeight = gestureView.frame.size.height;
            originWidth = gestureView.frame.size.width;
            originOffsetPoint = CGPointMake(gestureView.frame.origin.x, gestureView.frame.origin.y);
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            movingTranslation = [gesture translationInView:parentView];
            CGFloat offsetX = originOffsetPoint.x + movingTranslation.x;
            CGFloat offsetY = originOffsetPoint.y + movingTranslation.y;
            CGFloat scaleRatio = MIN(1.0, 1.5 - offsetY / parentView.frame.size.height);
            CGFloat alphaRatio = 1.0 - offsetY / parentView.frame.size.height;
            parentView.alpha = alphaRatio;
            CGRect rect = CGRectMake(offsetX + (originWidth * (1 - scaleRatio)) / 2.0, offsetY, originWidth * scaleRatio, originHeight * scaleRatio);
            gestureView.frame = rect;
        }
        else if (gesture.state == UIGestureRecognizerStateEnded) {
            movingTranslation = [gesture translationInView:parentView];
            CGFloat offsetY = originOffsetPoint.y + movingTranslation.y;
            BOOL hidden = offsetY > parentView.frame.size.height * 0.2;
            if (hidden && hideHander) {
                hideHander();
            }
            else {
                parentView.alpha = 1.0;
                self.frame = CGRectMake(originOffsetPoint.x, originOffsetPoint.y, originWidth, originHeight);
            }
        }
        else if (gesture.state == UIGestureRecognizerStateCancelled) {
            parentView.alpha = 1.0;
            self.frame = CGRectMake(originOffsetPoint.x, originOffsetPoint.y, originWidth, originHeight);
        }
    }];
    [self addGestureRecognizer:panGesture];
    return panGesture;
}

@end

NS_ASSUME_NONNULL_END
