//
//  BJPChatMessageViewController.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#import <BJLiveBase/BJLiveBase+UIKit.h>
#import <BJLiveBase/UITableView+BJLHeightCache.h>

#import "BJPChatMessageViewController.h"
#import "BJPChatMessageTableViewCell.h"
#import "BJPAppearance.h"

static NSInteger const pageSize = 50;

NS_ASSUME_NONNULL_BEGIN

@interface BJPChatMessageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) BJVRoom *room;
@property (nonatomic) NSMutableArray<BJLMessage *> *allMessages;
@property (nonatomic) NSMutableArray<BJLMessage *> *loadedMessages;

@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic) BOOL wasAtTheBottomOfTableView;
@property (nonatomic) BOOL loadingMore;

@end

@implementation BJPChatMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToTheEndTableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.wasAtTheBottomOfTableView = [self atTheBottomOfTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.scrollIndicatorInsets = bjl_set(self.tableView.scrollIndicatorInsets, {
        CGFloat adjustment = CGRectGetWidth(self.view.frame) - 8.5; // 8.5 = 2.5 + 3.0 * 2;
        set.left = - adjustment;
        set.right = adjustment;
    });
    
    if (self.wasAtTheBottomOfTableView && ![self atTheBottomOfTableView]) {
        [self scrollToTheEndTableView];
    }
}

- (void)loadView {
    self.view = [BJLHitTestView viewWithFrame:[UIScreen mainScreen].bounds hitTestBlock:^UIView * _Nullable(UIView * _Nullable hitView, CGPoint point, UIEvent * _Nullable event) {
       
        UITableViewCell *cell = [hitView bjl_closestViewOfClass:[UITableViewCell class] includeSelf:NO];
        if (cell && hitView != cell.contentView) {
//            hitView.clipsToBounds = YES;
            return hitView;
        }
        return nil;
    }];
}

#pragma mark - subviews

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view).priorityHigh();
    }];
}

#pragma mark - observers

- (void)setupObserversWithRoom:(BJVRoom *)room {
    self.room = room;
    
    bjl_weakify(self);
    // 消息覆盖更新
    [self bjl_observe:BJLMakeMethod(room.messageVM, receivedMessagesDidOverwrite:)
             observer:^BOOL(NSArray<BJVMessage *> *messageArray){
                 bjl_strongify(self);
                 // !!!: 回放消息数有限，且 key 是唯一的，重置列表时不需要清除高度缓存
                 self.allMessages = [messageArray mutableCopy];
                 [self resetLoadedMessages];
                 [self.tableView reloadData];
                 [self scrollToTheEndTableView];
                 return YES;
             }];
    
    // 消息增量更新
    [self bjl_observe:BJLMakeMethod(room.messageVM, didReceiveMessages:)
             observer:^BOOL(NSArray<BJVMessage *> *messageArray){
                 bjl_strongify(self);
                 if (!messageArray.count) {
                     return YES;
                 }
                 [self.allMessages addObjectsFromArray:messageArray];
                 [self.loadedMessages addObjectsFromArray:messageArray];
                 BOOL wasAtTheBottom = [self atTheBottomOfTableView];
                 if (wasAtTheBottom && self.loadedMessages.count > pageSize) {
                     // !!!: 当前在 tableView 底部，reload 之后会再次滑动到底部，重置 self.loadedMessages，控制数目至最多 pageSize 条
                     [self resetLoadedMessages];
                 }
                 [self.tableView reloadData];
                 if (wasAtTheBottom) {
                     [self scrollToTheEndTableView];
                 }
                 return YES;
             }];
}

#pragma mark - uitableview dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loadedMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJVMessage *message = bjl_as([self.loadedMessages bjl_objectAtIndex:indexPath.row], BJVMessage);
    NSString *cellIdentifier = [BJPChatMessageTableViewCell cellIdentifierForMessageType:message.type];
    BJPChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                        forIndexPath:indexPath];
    [cell updateWithMessage:message
                placeholder:message.imageURLString ? [UIImage bjp_imageNamed:@"bjp_img_placeholder"] : nil
             tableViewWidth:CGRectGetWidth(self.tableView.bounds)];
    
    bjl_weakify(self);
    cell.updateCellConstraintsCallback = cell.updateCellConstraintsCallback ?: ^(BJPChatMessageTableViewCell * _Nullable cell) {
        bjl_strongify(self);
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            BOOL wasAtTheBottomOfTableView = [self atTheBottomOfTableView];
            [self.tableView bjl_clearHeightCachesWithKey:[self keyWithIndexPath:indexPath message:message]];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if (wasAtTheBottomOfTableView) {
                [self scrollToTheEndTableView];
            }
        }
    };
    
    return cell;
}

- (void)scrollToTheEndTableView {
    NSInteger section = 0;
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:section];
    if (numberOfRows <= 0) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows - 1
                                                inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

- (CGFloat)atTheTopOfTableView {
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat top = self.tableView.contentInset.top;
    CGFloat topOffset = contentOffsetY + top;
    return topOffset <= 0.0;
}

- (CGFloat)atTheBottomOfTableView {
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat bottom = self.tableView.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(self.tableView.frame);
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    return bottomOffset >= 0.0 - BJPViewSpaceS;
}

#pragma mark - delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJVMessage *message = bjl_as([self.loadedMessages bjl_objectAtIndex:indexPath.row], BJVMessage);
    NSString *key = [self keyWithIndexPath:indexPath message:message];
    NSString *identifier = [BJPChatMessageTableViewCell cellIdentifierForMessageType:message.type];
    void (^configuration)(BJPChatMessageTableViewCell *cell) =
    ^(BJPChatMessageTableViewCell *cell) {
        cell.bjl_autoSizing = YES;
        [cell updateWithMessage:message
                    placeholder:message.imageURLString ? [UIImage bjp_imageNamed:@"bjp_img_placeholder"] : nil
                 tableViewWidth:CGRectGetWidth(self.tableView.bounds)];
    };
    
    return [tableView bjl_cellHeightWithKey:key identifier:identifier configuration:configuration];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BJVMessage *message = bjl_as([self.loadedMessages bjl_objectAtIndex:indexPath.row], BJVMessage);
    if (message && message.type == BJLMessageType_image) {
        BJPChatMessageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (self.showImageBrowserCallback) {
            self.showImageBrowserCallback(cell.imgView);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!scrollView.dragging && !scrollView.decelerating) {
        return;
    }
    
    if ([self atTheTopOfTableView] && !self.loadingMore) {
        [self loadMoreMessages];
    }
}

#pragma mark - get set

- (NSString *)keyWithIndexPath:(NSIndexPath *)indexPath message:(BJVMessage *)message {
    NSString *key = [NSString stringWithFormat:@"%@-%@-%td", message.ID, message.fromUser.ID, message.offsetTimestamp];
    return key;
}

- (NSMutableArray<BJLMessage *> *)allMessages {
    if (!_allMessages) {
        _allMessages = [NSMutableArray array];
    }
    return _allMessages;
}

- (NSMutableArray<BJLMessage *> *)loadedMessages {
    if (!_loadedMessages) {
        _loadedMessages = [NSMutableArray array];
    }
    return _loadedMessages;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
            tableView.showsVerticalScrollIndicator = NO;
            tableView.translatesAutoresizingMaskIntoConstraints = NO;
            tableView.allowsSelection = YES;
            tableView.contentInset = bjl_set(tableView.contentInset, {
                set.top = set.bottom = BJPViewSpaceS;
            });
            tableView.scrollIndicatorInsets = bjl_set(tableView.contentInset, {
                set.top = set.bottom = BJPViewSpaceS;
            });
            for (NSString *cellIdentifier in [BJPChatMessageTableViewCell allCellIdentifiers]) {
                [tableView registerClass:[BJPChatMessageTableViewCell class]
                   forCellReuseIdentifier:cellIdentifier];
            }
            tableView.rowHeight = UITableViewAutomaticDimension;
            tableView.estimatedRowHeight = [BJPChatMessageTableViewCell estimatedRowHeightForMessageType:BJLMessageType_text];
            tableView;
        });
    }
    return _tableView;
}

#pragma mark - private

- (void)resetLoadedMessages {
    [self.loadedMessages removeAllObjects];
    NSInteger allCount = self.allMessages.count;
    NSInteger loadCount = MIN(allCount, pageSize);
    NSInteger loadStartIndex = MAX(allCount - loadCount, 0);
    if (loadCount > 0) {
        self.loadedMessages = [[self.allMessages subarrayWithRange:NSMakeRange(loadStartIndex, loadCount)] mutableCopy];
        self.loadingMore = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.loadingMore = NO;
        });
        // !!!: no reloadData
    }
}

- (void)loadMoreMessages {
    NSInteger loadedCount = self.loadedMessages.count;
    NSInteger allCount = self.allMessages.count;
    NSInteger loadCount = MIN(allCount - loadedCount, pageSize);
    NSInteger loadStartIndex = MAX(allCount - loadedCount - loadCount, 0);
    
    if (loadCount > 0) {
        self.loadedMessages = [[self.allMessages subarrayWithRange:NSMakeRange(loadStartIndex, loadCount + loadedCount)] mutableCopy];
        // !!!: 0.5 秒之内只触发一次
        self.loadingMore = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.loadingMore = NO;
        });
        
        // !!!: reload 时不响应拖动，避免画面跳动
        self.tableView.scrollEnabled = NO;
        [self.tableView reloadData];
        self.tableView.scrollEnabled = YES;
        
        // !!!: 滑动到加载前的消息处
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:loadCount inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

@end

NS_ASSUME_NONNULL_END
