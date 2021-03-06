//
//  MBProgressHUD+bjp.m
//  BJPlaybackCore
//
//  Created by 辛亚鹏 on 2017/3/17.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//

#import "MBProgressHUD+bjpb.h"

@implementation BJLProgressHUD (bjpb)

+ (void)bjpb_showMessageThenHide:(NSString *)msg toView:(UIView *)view onHide:(void (^)(void))onHide {
    [self bjpb_showMessageThenHide:msg toView:view yOffset:0 onHide:onHide];
}

+ (void)bjpb_showMessageThenHide:(NSString *)msg
                         toView:(UIView *)view  yOffset:(CGFloat)offset
                         onHide:(void (^)(void))onHide {
    if (!view){
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    NSAssert(!!view, @" no view");
    
    // 移除上一个 HUD
    BJLProgressHUD *lastHud = [BJLProgressHUD bjl_hudForLoadingWithSuperview:view];
    if (lastHud) {
        [lastHud hideAnimated:NO];
        [lastHud removeFromSuperview];
    }
    
    // 显示新的提示信息
    BJLProgressHUD *hud = [BJLProgressHUD bjl_showHUDForLoadingWithSuperview:view animated:YES];
    NSAssert(!!hud, @"hud is nil");
    hud.detailsLabel.font = [UIFont systemFontOfSize:16];
    hud.detailsLabel.text = msg;
    
    // 再设置模式
    hud.mode = BJLMBProgressHUDModeText;
    [hud setUserInteractionEnabled:false];
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    //    hud.dimBackground = NO;
    hud.backgroundView.color = [UIColor clearColor];
    //    hud.yOffset = offset;
    hud.offset = CGPointMake(hud.offset.x, offset);
    // 5秒之后再消失
    int hideInterval = 5;
    [hud hideAnimated:YES afterDelay:hideInterval];
    
    if (onHide){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(hideInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onHide();
        });
    }
}

+ (BJLProgressHUD *)bjpb_showLoading:(NSString*)msg toView:(UIView *)view yOffset:(CGFloat)offset {
    if (!view) {
        return nil;
    }
    
    // 移除上一个 HUD
    BJLMBProgressHUD *lastHud = [BJLMBProgressHUD HUDForView:view];
    if (lastHud) {
        [lastHud hideAnimated:NO];
        [lastHud removeFromSuperview];
    }
    
    // 显示新的提示信息
    BJLProgressHUD *hud = [BJLProgressHUD bjl_showHUDForLoadingWithSuperview:view animated:YES];
    if (hud == nil) {
        return hud;
    }
    hud.detailsLabel.text = msg;
    //    hud.yOffset = offset;
    hud.offset = CGPointMake(hud.offset.x, offset);
    hud.detailsLabel.font = [UIFont systemFontOfSize:16];
    
    // 再设置模式
    hud.mode = BJLMBProgressHUDModeIndeterminate;
    hud.userInteractionEnabled = NO;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}


+ (BJLProgressHUD *)bjpb_showLoading:(NSString*)msg toView:(UIView *)view {
    return [BJLProgressHUD bjpb_showLoading:msg toView:view yOffset:0];
}

+ (void)bjpb_closeLoadingView:(UIView *)toView {
    BJLMBProgressHUD *hud = [BJLMBProgressHUD HUDForView:toView];
    if (hud) {
        [hud hideAnimated:YES];
        [hud removeFromSuperview];
    }
}
@end
