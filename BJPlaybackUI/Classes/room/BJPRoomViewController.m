//
//  BJPRoomViewController.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/22.
//
//

#import <BJLiveBase/BJLiveBase.h>

#import "BJPRoomViewController.h"
#import "BJPRoomViewController+protected.h"
#import "BJPlaybackUI.h"

@interface BJPRoomViewController () <BJPSliderProtocol>

@end

@implementation BJPRoomViewController

#pragma mark - public

+ (void)load {
    [[BJLUserAgent defaultInstance] registerSDK:BJPlaybackUIName() version:BJPlaybackUIVersion()];
}

- (instancetype)initWithRoom:(BJVRoom *)room options:(BJPPlaybackOptions *)options {
    NSParameterAssert(room);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
        self.playbackOptions = options;
        [self setupPlayerManager];
    }
    return self;
}

+ (__kindof instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                             sessionID:(nullable NSString *)sessionID
                                                 token:(NSString *)token; {
    BJVRoom *room = [BJVRoom onlinePlaybackRoomWithClassID:classID sessionID:sessionID token:token];
    return [[self alloc] initWithRoom:room options:[BJPPlaybackOptions new]];
}

+ (__kindof instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                             sessionID:(nullable NSString *)sessionID
                                                 token:(NSString *)token
                                             accessKey:(nullable NSString *)accessKey
                                               options:(BJPPlaybackOptions *)options {
    BJVRoom *room = [BJVRoom onlinePlaybackRoomWithClassID:classID
                                                 sessionID:sessionID
                                                     token:token
                                                 encrypted:options.encryptEnabled
                                                 accessKey:accessKey
                                                playerType:options.playerType];
    room.disablePPTAnimation = options.disablePPTAnimation;
    return [[self alloc] initWithRoom:room options:options];
}

+ (__kindof instancetype)localPlaybackRoomWithDownloadItem:(BJVDownloadItem *)downloadItem {
    BJVRoom *room = [BJVRoom localPlaybackRoomWithDownloadItem:downloadItem
                                                    playerType:BJVPlayerType_AVPlayer];
    return [[self alloc] initWithRoom:room options:[BJPPlaybackOptions new]];
}

+ (__kindof instancetype)localPlaybackRoomWithDownloadItem:(BJVDownloadItem *)downloadItem
                                                   options:(BJPPlaybackOptions *)options {
    BJVRoom *room = [BJVRoom localPlaybackRoomWithDownloadItem:downloadItem
                                                    playerType:options.playerType];
    return [[self alloc] initWithRoom:room options:options];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor bjp_grayLineColor];
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 130000) // __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
    
    [self setupSubviews];
    [self setupPlaybackControlCallbacks];
    [self addObserversForPlaybackRoom];

    //ppt不支持交互
    self.room.slideshowViewController.view.userInteractionEnabled = NO;
    [self.room enter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL isHorizontal = BJPIsHorizontalUI(self);
    [self updateConstraintsForHorizontal:isHorizontal];
}

// NOTE: trigger by [self setNeedsStatusBarAppearanceUpdate];
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    BOOL isHorizontal = BJPIsHorizontalUI(self);
    return (self.imageBrowserViewController.parentViewController
            || self.room.slideshowViewController.drawingEnabled
            || (isHorizontal && self.playbackControlView.controlsHidden)
            || (isHorizontal && !self.overlayViewController.view.hidden));
    // TODO: 显示 overlayViewController 时是否隐藏状态栏，支持由 contentViewController 设置 - 要区分横竖屏
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(self.room.isInteractiveClass) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else {
        return (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone
                ? UIInterfaceOrientationMaskAllButUpsideDown
                : UIInterfaceOrientationMaskAll);
    }
}

#pragma mark - <UIContentContainer>

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self setNeedsStatusBarAppearanceUpdate];
        [self.view setNeedsUpdateConstraints];
        BOOL isHorizontal = BJPIsHorizontalUI(self);
        [self updateConstraintsForHorizontal:isHorizontal];
    } completion:nil];
}

- (void)askToExit {
    UIAlertController *alert = [UIAlertController
                                bjl_lightAlertControllerWithTitle:@"确定退出教室？"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self exit];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)exit {
    if (self.reachabilityManager) {
        [self.reachabilityManager stopMonitoring];
    }
    
    if (self.room) {
        [self.room exit];
        [self clean];
    }
    
    [self cleanOverlayViews];
    
    [self bjl_stopAllKeyValueObserving];
    [self bjl_stopAllMethodParametersObserving];
    void (^completion)(void) = ^{
        [self roomDidExit];
    };
    
    UINavigationController *navigation = [self.parentViewController bjl_as:[UINavigationController class]];
    BOOL isRoot = (navigation
                   && self == navigation.topViewController
                   && self == navigation.bjl_rootViewController);
    UIViewController *outermost = isRoot ? navigation : self;

    // pop
    if (navigation && !isRoot) {
        [navigation bjl_popViewControllerAnimated:YES completion:completion];
    }
    // dismiss
    else if (!outermost.parentViewController && outermost.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
    // close in `roomViewController:didExitWithError:`
    else {
        completion();
    }
}

- (BJLObservable)roomDidExit {
    BJLMethodNotify((void));
}

- (void)clean {
    self->_room = nil;
}

#pragma mark - constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - playerManager

- (void)setupPlayerManager {
    BJVPlayerManager *playerManager = self.room.playerManager;
    BJPPlaybackOptions *options = self.playbackOptions;
    playerManager.userName =  options.userName;
    playerManager.userNumber = options.userNumber;
    playerManager.backgroundAudioEnabled = options.backgroundAudioEnabled;
    playerManager.preferredDefinitionList = options.preferredDefinitionList;
    playerManager.playTimeRecordEnabled = options.playTimeRecordEnabled;
    playerManager.initialPlayTime = options.initialPlayTime;
}

#pragma mark - BJPSliderProtocol

- (CGFloat)originValueForTouchSlideView:(BJPSliderView *)touchSlideView {
    return self.room.playerManager.currentTime;
}

- (CGFloat)durationValueForTouchSlideView:(BJPSliderView *)touchSlideView {
    return self.room.playerManager.duration;
}

- (void)touchSlideView:(BJPSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value {
    [self.room.playerManager seek:value];
}

#pragma mark - lazy load properties

@synthesize rateList = _rateList;
- (NSArray<NSNumber *> *)rateList {
    if (!_rateList) {
        // iOS 10以下系统在 0.7、1.2 倍速时会出现音视频不同步，换成 0.8、1.25
        if (@available(iOS 10.0, *)) {
            _rateList = @[@0.7, @1.0, @1.2, @1.5, @2.0];
        }
        else {
            _rateList = @[@0.8, @1.0, @1.25, @1.5, @2.0];
        }
    }
    return _rateList;
}

@synthesize fullScreenContainerView = _fullScreenContainerView;
- (BJPFullScreenContainerView *)fullScreenContainerView {
    return _fullScreenContainerView ?: (_fullScreenContainerView = ({
        BJPFullScreenContainerView *view = [[BJPFullScreenContainerView alloc] init];
        view.accessibilityLabel = BJLKeypath(self, fullScreenContainerView);
        view;
    }));
}

@synthesize thumbnailContainerView = _thumbnailContainerView;
- (BJPThumbnailContainerView *)thumbnailContainerView {
    return _thumbnailContainerView ?: (_thumbnailContainerView = ({
        BJPThumbnailContainerView *view = [[BJPThumbnailContainerView alloc] init];
        view.accessibilityLabel = BJLKeypath(self, thumbnailContainerView);
        view;
    }));
}

@synthesize playbackControlView = _playbackControlView;
- (BJPPlaybackControlView *)playbackControlView {
    return _playbackControlView ?: (_playbackControlView = ({
        BJPPlaybackControlView *view = [[BJPPlaybackControlView alloc] init];
        [view setSlideEnable:self.playbackOptions.sliderDragEnabled];
        view.accessibilityLabel = BJLKeypath(self, playbackControlView);
        view;
    }));
}

@synthesize mediaSettingView = _mediaSettingView;
- (BJPMediaSettingView *)mediaSettingView {
    return _mediaSettingView ?: (_mediaSettingView = ({
        BJPMediaSettingView *view = [[BJPMediaSettingView alloc] init];
        view.accessibilityLabel = BJLKeypath(self, mediaSettingView);
        view.hidden = YES;
        view;
    }));
}

@synthesize audioOnlyImageView = _audioOnlyImageView;
- (UIImageView *)audioOnlyImageView {
    return _audioOnlyImageView ?: (_audioOnlyImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage bjp_imageNamed:@"bjp_img_audio_only"];
        imageView.accessibilityLabel = BJLKeypath(self, audioOnlyImageView);
        imageView;
    }));
}

@synthesize controlLayer = _controlLayer;
- (UIView *)controlLayer {
    return _controlLayer ?: (_controlLayer = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityLabel = BJLKeypath(self, controlLayer);
        view;
    }));
}

@synthesize messageViewContrller = _messageViewContrller;
- (BJPChatMessageViewController *)messageViewContrller {
    return _messageViewContrller ?: (_messageViewContrller = ({
        BJPChatMessageViewController *controller = [[BJPChatMessageViewController alloc] init];
        [controller setupObserversWithRoom:self.room];
        controller;
    }));
}

@synthesize usersViewController = _usersViewController;
- (BJPUsersViewController *)usersViewController {
    return _usersViewController ?: (_usersViewController = ({
        BJPUsersViewController *controller = [[BJPUsersViewController alloc] init];
        [controller setupObserversWithRoom:self.room];
        controller;
    }));
}

@synthesize imageBrowserViewController = _imageBrowserViewController;
- (BJPImageBrowserViewController *)imageBrowserViewController {
    return _imageBrowserViewController ?: (_imageBrowserViewController = ({
        BJPImageBrowserViewController *controller = [BJPImageBrowserViewController new];
        bjl_weakify(self);
        [controller setHideCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [UIView animateWithDuration:BJPAnimateDurationM
                             animations:^{
                                 self.imageBrowserViewController.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 self.imageBrowserViewController.imageView.image = nil;
                                 [self.imageBrowserViewController bjl_removeFromParentViewControllerAndSuperiew];
                                 [self setNeedsStatusBarAppearanceUpdate];
                             }];
        }];
        controller;
    }));
}

@synthesize overlayViewController = _overlayViewController;
- (BJPOverlayViewController *)overlayViewController {
    return _overlayViewController ?: (_overlayViewController = ({
        BJPOverlayViewController *controller = [[BJPOverlayViewController alloc] init];
        controller.view.hidden = YES;
        controller;
    }));
}

@synthesize quizContainLayer = _quizContainLayer;
- (UIView *)quizContainLayer {
    return _quizContainLayer ?: (_quizContainLayer = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityLabel = BJLKeypath(self, quizContainLayer);
        view;
    }));
}

@end
