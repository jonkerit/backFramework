//
//  BJPMediaSettingView.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/14.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPMediaSettingView.h"
#import "BJPAppearance.h"
#import "BJPMediaSettingCell.h"

#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import <BJLiveBase/BJL_EXTScope.h>

static NSString * const cellIdentifier = @"settingCell";
static CGFloat const rowHeight = 40.0;

@interface BJPMediaSettingView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray<NSString *> *options;
@property (nonatomic) NSUInteger selectIndex;
@property (nonatomic) BJPMediaSettingType type;

@end

@implementation BJPMediaSettingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor bjp_lightDimColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [self addGestureRecognizer:tapGesture];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subviews

- (void)setupSubviews {
    [self addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self);
        make.top.greaterThanOrEqualTo(self);
        make.bottom.lessThanOrEqualTo(self);
        make.width.equalTo(@(200.0));
        make.height.equalTo(@0.0).priorityHigh(); // to update
    }];
}

#pragma mark - show & update

- (void)showWithSettingOptons:(NSArray<NSString *> *)options
                         type:(BJPMediaSettingType)type
                  selectIndex:(NSUInteger)selectIndex {
    self.type = type;
    [self updateWithSettingOptons:options type:type selectIndex:selectIndex];
    self.hidden = NO;
}

- (void)updateWithSettingOptons:(NSArray<NSString *> *)options
                           type:(BJPMediaSettingType)type
                    selectIndex:(NSUInteger)selectIndex {
    if (self.type != type) {
        return;
    }
    
    self.options = options;
    self.selectIndex = selectIndex;
    
    [self.tableView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.height.equalTo(@(options.count * rowHeight)).priorityHigh();
    }];
    [self.tableView reloadData];
}

#pragma mark - actions

- (void)cancel {
    self.hidden = YES;
}

- (void)optionSelected {
    if (self.selectCallback) {
        self.selectCallback(self.type, self.selectIndex);
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    NSString *option = [[self.options objectAtIndex:index] bjl_as:[NSString class]];
    BJPMediaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    BOOL selected = (index == self.selectIndex);
    [cell updateWithSettingTitle:option selected:selected];
    bjl_weakify(self);
    [cell setSelectCallback:^{
        bjl_strongify(self);
        self.selectIndex = index;
        [self.tableView reloadData];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(optionSelected) object:nil];
        [self performSelector:@selector(optionSelected) withObject:nil afterDelay:0.8];
        [self cancel];
    }];
    return cell;
}

#pragma mark - getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.bounces = NO;
            tableView.rowHeight = rowHeight;
            if (@available(iOS 9.0, *)) {
                tableView.cellLayoutMarginsFollowReadableWidth = NO;
            }
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[BJPMediaSettingCell class] forCellReuseIdentifier:cellIdentifier];
            tableView;
        });
    }
    return _tableView;
}

@end
