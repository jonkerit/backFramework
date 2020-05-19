//
//  BJPRoomViewController.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/22.
//
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLiveBase.h>
#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

#import "BJPPlaybackOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPRoomViewController : UIViewController
/// 修改了
/** 回放教室
 参考 `BJPlaybackCore` */
@property (nonatomic, readonly, nullable) BJVRoom *room;

/**
 创建回放的room,使用该接口播放回放,则默认使用AVPlayer,且播放的是不加密的视频
 创建在线视频, 参数不可传空
 创建本地room的话, 两个参数传nil
 
 @param classID classID
 @param sessionID sessionID 长期房间回放课节参数。如果 classID 对应的课程不是长期房间,可不传;如果 classID 对应的课程是长期房间, 不传则默认返回长期房间的第一个课程。
 @param token token
 @return room
 */
+ (__kindof instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                             sessionID:(nullable NSString *)sessionID
                                                 token:(NSString *)token;

/**
 创建回放的room,使用该接口播放回放,可以选择使用avplayer或者ijkplayer播放视频,以及是否使用加密视频
 !!!:只有使用ijkplayer才可以播放加密视频,因此选择avplayer播放视频时,是否加密的参数设置无效
 创建在线视频, 参数不可传空
 创建本地room的话, 两个参数传nil
 
 @param classID classID
 @param sessionID sessionID 长期房间回放课节参数。如果 classID 对应的课程不是长期房间,可不传; 如果classId对应的课程是长期房间, 不传则默认返回长期房间的第一个课程。
 @param token token
 @param options 回放设置
 @return room
 */
+ (__kindof instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                             sessionID:(nullable NSString *)sessionID
                                                 token:(NSString *)token
                                             accessKey:(nullable NSString *)accessKey
                                               options:(BJPPlaybackOptions *)options;

/**
 创建播放本地视频  
 
 @param downloadItem 本地回放文件类型，通过下载模块获得
 */

+ (__kindof instancetype)localPlaybackRoomWithDownloadItem:(BJVDownloadItem *)downloadItem;

+ (__kindof instancetype)localPlaybackRoomWithDownloadItem:(BJVDownloadItem *)DownloadItem
                                                   options:(BJPPlaybackOptions *)options;

/** 退出教室 */
- (void)exit;

- (BJLObservable)roomDidExit;

@end

NS_ASSUME_NONNULL_END
