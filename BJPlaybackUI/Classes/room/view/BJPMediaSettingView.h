//
//  BJPMediaSettingView.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/14.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BJPMediaSettingType) {
    BJPMediaSettingType_Unknown,
    BJPMediaSettingType_Definition,
    BJPMediaSettingType_Rate
};

NS_ASSUME_NONNULL_BEGIN

@class BJPMediaSettingOption;

@interface BJPMediaSettingView : UIView

@property (nonatomic, copy) void (^selectCallback)(BJPMediaSettingType type,NSUInteger selectIndex);

- (void)showWithSettingOptons:(NSArray<NSString *> *)options
                         type:(BJPMediaSettingType)type
                  selectIndex:(NSUInteger)selectIndex;

- (void)updateWithSettingOptons:(NSArray<NSString *> *)options
                           type:(BJPMediaSettingType)type
                    selectIndex:(NSUInteger)selectIndex;

@end

NS_ASSUME_NONNULL_END
