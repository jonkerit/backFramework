//
//  BJPChatMessageViewController.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPChatMessageViewController : UIViewController

@property (nonatomic, copy, nullable) void (^showImageBrowserCallback)(UIImageView *imageView);

- (void)setupObserversWithRoom:(BJVRoom *)room;

@end

NS_ASSUME_NONNULL_END
