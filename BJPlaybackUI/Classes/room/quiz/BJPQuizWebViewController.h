//
//  BJPQuizWebViewController.h
//  BJPlaybackUI
//
//  Created by fanyi on 2019/8/19.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveBase/BJLWebViewController.h>
#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPQuizWebViewController : BJLWebViewController

@property (nonatomic, copy, nullable) BJLError * _Nullable (^sendQuizMessageCallback)(NSDictionary<NSString *, id> *message);
@property (nonatomic, copy, nullable) void (^closeWebViewCallback)(void);

+ (nullable instancetype)instanceWithQuizMessage:(NSDictionary<NSString *, id> *)message roomVM:(BJVRoomVM *)roomVM;
+ (NSDictionary *)quizReqMessageWithUserNumber:(NSString *)userNumber;

- (void)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message;

@end

NS_ASSUME_NONNULL_END
