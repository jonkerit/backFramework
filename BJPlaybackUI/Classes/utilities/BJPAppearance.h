//
//  BJPAppearance.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/22.
//
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import <BJLiveBase/BJLiveBase.h>

NS_ASSUME_NONNULL_BEGIN

#define YPWeakObj(objc) autoreleasepool{} __weak typeof(objc) objc##Weak = objc;
#define YPStrongObj(objc) autoreleasepool{} __strong typeof(objc) objc = objc##Weak;

#define BJPOnePixel (1.0/[UIScreen mainScreen].scale)

/**
 用于判断  是否横屏模式
 */
static inline BOOL BJPIsHorizontalUI(id<UITraitEnvironment> traitEnvironment) {
    return !(traitEnvironment.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
             && traitEnvironment.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
}

static inline CGSize BJPImageViewSize(CGSize imgSize, CGSize minSize, CGSize maxSize) {
    CGFloat minScale = MAX(imgSize.width / maxSize.width, imgSize.height / maxSize.height);
    CGFloat maxScale = MIN(imgSize.width / minSize.width, imgSize.height / minSize.height);
    CGFloat scale = MIN(MAX(minScale, 1.0), maxScale); // 等比显示、最少缩放
    return CGSizeMake(MIN(imgSize.width / scale, maxSize.width),
                      MIN(imgSize.height / scale, maxSize.height)); // 超出部分裁切
}

extern const CGFloat BJPViewSpaceS, BJPViewSpaceM, BJPViewSpaceL;
extern const CGFloat BJPControlSize;

extern const CGFloat BJPSmallViewHeight, BJPSmallViewWidth;

extern const CGFloat BJPButtonHeight, BJPButtonWidth;

extern const CGFloat BJPButtonSizeS, BJPButtonSizeM, BJPButtonSizeL, BJPButtonCornerRadius;
extern const CGFloat BJPBadgeSize;
extern const CGFloat BJPScrollIndicatorSize;

extern const CGFloat BJPAnimateDurationS, BJPAnimateDurationM;
extern const CGFloat BJPRobotDelayS, BJPRobotDelayM;

@interface UIColor (BJPColorLegend)

// common
@property (class, nonatomic, readonly) UIColor
*bjp_darkGrayBackgroundColor,
*bjp_lightGrayBackgroundColor,

*bjp_darkGrayTextColor,
*bjp_grayTextColor,
*bjp_lightGrayTextColor,

*bjp_grayBorderColor,
*bjp_grayLineColor,
*bjp_grayImagePlaceholderColor, // == bjp_grayLineColor

*bjp_blueBrandColor,
*bjp_orangeBrandColor,
*bjp_redColor;

// dim
@property (class, nonatomic, readonly) UIColor
*bjp_lightMostDimColor, // black-0.2
*bjp_lightDimColor, // black-0.5
*bjp_dimColor,      // black-0.6
*bjp_darkDimColor;  // black-0.7

@end

@interface UIImage (BJPlaybackUI)

+ (UIImage *)bjp_imageNamed:(NSString *)name;

@end

@interface UIImageView (BJPlaybackUI)

/**
 pan to hide image
 
 @param hideHander hide hander
 @param customerHander customer hander before this hander
 @param parentView parent view to hanle this gesture, eg: update alpha, size
 @return gesture
 */
- (UIPanGestureRecognizer *)bjp_makePanGestureToHide:(nullable void (^)(void))hideHander customerHander:(nullable void (^)(UIPanGestureRecognizer * _Nullable))customerHander parentView:(UIView *)parentView;

@end

NS_ASSUME_NONNULL_END
