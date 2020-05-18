//
//  BJPImageBrowserViewController.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/28.
//
//

#import <BJLiveBase/BJLiveBase+UIKit.h>
#import <BJLiveBase/BJLAuthorization.h>

#import "BJPImageBrowserViewController.h"
#import "BJPAppearance.h"
#import "MBProgressHUD+bjpb.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPImageBrowserViewController ()

@property (nonatomic, readwrite) UIImageView *imageView;

@end

@implementation BJPImageBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bjp_darkGrayBackgroundColor];
    
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    [self.imageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(closeWithGestureRecognizer:)];
    [self.view addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(saveWithGestureRecognizer:)];
    [self.view addGestureRecognizer:longPressGesture];
    [tapGesture requireGestureRecognizerToFail:longPressGesture];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView bjp_makePanGestureToHide:^{
        [self hide];
    } customerHander:nil parentView:self.view];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)closeWithGestureRecognizer:(UITapGestureRecognizer *)tap {
    [self hide];
}

- (void)saveWithGestureRecognizer:(UILongPressGestureRecognizer *)longPress {
    if (!self.imageView.image || longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIAlertController *actionSheet = [UIAlertController
                                      bjl_lightAlertControllerWithTitle:@"保存图片"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
    @YPWeakObj(self);
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @YPStrongObj(self);
        [BJLAuthorization checkPhotosAccessAndRequest:YES callback:^(BOOL granted, UIAlertController * _Nullable alert) {
            if (granted) {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            else if (alert) {
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];

    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    actionSheet.popoverPresentationController.sourceView = self.imageView;
    actionSheet.popoverPresentationController.sourceRect = ({
        CGRect rect = self.imageView.bounds;
        rect.origin.y = CGRectGetMaxY(rect) - 1.0;
        rect.size.height = 1.0;
        rect;
    });
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = error ? [NSString stringWithFormat:@"保存图片出错: %@", [error localizedDescription]] : @"图片已保存";
//    UIViewController *vc = [self targetViewControllerForAction:@selector(showProgressHUDWithText:) sender:self];
//    [vc showProgressHUDWithText:message];
    [BJLProgressHUD bjpb_showMessageThenHide:message toView:self.view onHide:nil];
    
}

- (void)hide {
    if (self.hideCallback) self.hideCallback(self);
}

@end

NS_ASSUME_NONNULL_END
