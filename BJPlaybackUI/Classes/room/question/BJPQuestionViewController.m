//
//  BJPQuestionViewController.m
//  BJPlaybackUI
//
//  Created by xijia dai on 2019/12/5.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

#import "BJPQuestionViewController.h"
#import "BJPAppearance.h"
#import "BJPQuestionCell.h"

@interface BJPQuestionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) NSMutableArray<BJLQuestion *> *questionList;

@property (nonatomic) UIPanGestureRecognizer *gesture;
@property (nonatomic, nullable) UIView *overlayView;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIImageView *emptyView;

@end

@implementation BJPQuestionViewController
- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self->_room = room;
        self.questionList = [NSMutableArray new];
        [self makeObserving];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeSubviewsAndConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateQuestionEmptyViewHidden:self.questionList.count];
    if (self.showRedDotCallback) {
        self.showRedDotCallback(NO);
    }
}

#pragma mark - subviews

- (void)makeSubviewsAndConstraints {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    [self.view addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.edges.equalTo(self.view);
    }];
    
    // table view
    [self.tableView removeFromSuperview];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor bjp_lightGrayBackgroundColor];
    for (NSString *identifier in [BJPQuestionCell allCellIdentifiers]) {
        [self.tableView registerClass:[BJPQuestionCell class] forCellReuseIdentifier:identifier];
    }
    [self.containerView addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.edges.equalTo(self.containerView);
    }];
    
    self.emptyView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.hidden = YES;
        imageView.image = [UIImage bjp_imageNamed:@"bjp_ic_question_empty"];
        imageView;
    });
    [self.containerView insertSubview:self.emptyView aboveSubview:self.tableView];
    [self.emptyView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.center.equalTo(self.containerView);
        make.width.equalTo(self.containerView).multipliedBy(0.3);
        make.height.equalTo(self.emptyView.bjl_width).multipliedBy(self.emptyView.image.size.height / self.emptyView.image.size.width);
    }];
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);
    
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didResetQuestion)
             observer:^BOOL{
                bjl_strongify(self);
                [self.questionList removeAllObjects];
                if (self.showRedDotCallback) {
                    self.showRedDotCallback(NO);
                }
                if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                    return YES;
                }
                [self.tableView reloadData];
                [self updateQuestionEmptyViewHidden:self.questionList.count];
                return YES;
            }];
    
    [self bjl_observeMerge:@[BJLMakeMethod(self.room.roomVM, didPublishQuestion:),
                             BJLMakeMethod(self.room.roomVM, didReplyQuestion:)]
                  observer:^(BJLQuestion *question) {
                      bjl_strongify(self);
                      // 回复问答
                      [self updateQuestionListWithQuestion:question];
                      if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                          if (self.showRedDotCallback) {
                              self.showRedDotCallback(YES);
                          }
                          return;
                      }
                      [self.tableView reloadData];
                      [self updateQuestionEmptyViewHidden:self.questionList.count];
                  }];
    
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didUnpublishQuestionWithQuestionID:)
             observer:^BOOL(NSString *questionID) {
                 bjl_strongify(self);
                 // 取消发布问答时只有问答ID，因此特殊处理
                 [self updateQuestionListWithQuestionID:questionID questionState:BJLQuestionUnpublished];
                 if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden) {
                     return YES;
                 }
                 [self.tableView reloadData];
                 [self updateQuestionEmptyViewHidden:self.questionList.count];
                 return YES;
             }];
}

#pragma mark - actions

- (void)updateQuestionEmptyViewHidden:(BOOL)hidden {
    if (self.emptyView.hidden == hidden) {
        return;
    }
    self.emptyView.hidden = hidden;
}

- (void)updateQuestionListWithQuestion:(BJLQuestion *)question {
    // 先判断是否存在同一个ID的问答，如果存在，替换，否则新增
    BOOL existQuestion = [self replaceQuestionListWithQuestion:question];
    if (!existQuestion) {
        // 如果没有更新问答，就作为新发布的问答处理
        [self updateQuestionListWithPublishQuestion:question];
    }
}

- (BOOL)replaceQuestionListWithQuestion:(BJLQuestion *)question {
    // !!! 更新问答
    BOOL existQuestion = NO;
    for (BJLQuestion *oldQuestion in [self.questionList copy]) {
        if ([oldQuestion.ID isEqualToString:question.ID]) {
            // 查找相同的问答，更新数据
            existQuestion = YES;
            NSUInteger index = [self.questionList indexOfObject:oldQuestion];
            [self.questionList bjl_replaceObjectAtIndex:index withObject:question];
        }
    }
    return existQuestion;
}

- (void)updateQuestionListWithPublishQuestion:(BJLQuestion *)question {
    // !!! 目前主要用于学生处理发布的问答，根据发布的新问答更新问答列表，发布的问答可能不是最新的问答，老师和助教在问答发送时就获得了问答，处理更新逻辑
    BOOL insertQuestion = NO;
    for (BJLQuestion *oldQuestion in [self.questionList copy]) {
        // 插入到第一个比新发布的问答序号大的前面
        if ([question.ID integerValue] < [oldQuestion.ID integerValue]) {
            NSInteger index = [self.questionList indexOfObject:oldQuestion];
            [self.questionList bjl_insertObject:question atIndex:index];
            insertQuestion = YES;
            break;
        }
    }
    if (!insertQuestion) {
        // 如果没有直接添加到末尾
        [self.questionList bjl_addObject:question];
    }
}

- (void)updateQuestionListWithQuestionID:(NSString *)questionID questionState:(BJLQuestionState)state {
    // !!! 目前主要用于处理取消发布的问答，删除问答数据
    for (BJLQuestion *question in [self.questionList copy]) {
        if ([question.ID isEqualToString:questionID]) {
            // 改变状态
            question.state = state;
            if (question.state &BJLQuestionUnpublished) {
                [self.questionList removeObject:question];
            }
            break;
        }
    }
}

- (void)hide {
    if (self.hideCallback) {
        self.hideCallback();
    }
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.questionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BJLQuestion *question = [self.questionList bjl_objectAtIndex:section];
    return question.replies.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLQuestion *question = [self.questionList bjl_objectAtIndex:indexPath.section];
    BJPQuestionCell *cell = nil;
    if (indexPath.row > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:BJPQuestionReplyCellReuseIdentifier forIndexPath:indexPath];
        [cell updateWithQuestion:nil questionReply:bjl_as([question.replies bjl_objectAtIndex:indexPath.row - 1], BJLQuestionReply)];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:BJPQuestionCellReuseIdentifier forIndexPath:indexPath];
        [cell updateWithQuestion:question questionReply:nil];
    }
    return cell;
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLQuestion *question = [self.questionList bjl_objectAtIndex:indexPath.section];
    BJLQuestionReply *questionReply;
    NSString *key;
    NSString *identifier;
    if (indexPath.row > 0) {
        questionReply = bjl_as([question.replies bjl_objectAtIndex:indexPath.row - 1], BJLQuestionReply);
        key = [NSString stringWithFormat:@"kQuestionKey %ld %f", (long)question.ID, questionReply.createTime];
        identifier = BJPQuestionReplyCellReuseIdentifier;
    }
    else {
        key = [NSString stringWithFormat:@"kQuestionKey %ld %f", (long)question.ID, question.createTime];
        identifier = BJPQuestionCellReuseIdentifier;
    }
    
    CGFloat height = [tableView bjl_cellHeightWithKey:key identifier:identifier configuration:^(BJPQuestionCell *cell) {
        //bjl_strongify(self);
        cell.bjl_autoSizing = YES;
        [cell updateWithQuestion:question questionReply:questionReply];
    }];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < [tableView numberOfSections] - 1) {
        return 10.0;
    }
    else if (section == [tableView numberOfSections] - 1) {
        // 最后的 section 加个边框线
        return 1.0;
    }
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section < [tableView numberOfSections] - 1) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor bjp_grayImagePlaceholderColor].CGColor;
        return view;
    }
    else if (section == [tableView numberOfSections] - 1) {
        // 最后的 section 加个边框线
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjp_grayImagePlaceholderColor];
        return view;
    }
    return nil;
}

#pragma mark -

- (BOOL)atTheBottomOfTableView {
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat bottom = self.tableView.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(self.tableView.frame);
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    CGFloat minCellHeight = 48.0;
    return bottomOffset >= 0.0 - minCellHeight;
}

@end
