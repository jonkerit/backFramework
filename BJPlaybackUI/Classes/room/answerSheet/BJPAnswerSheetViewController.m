//
//  BJPAnswerSheetViewController.m
//  BJPlaybackUI
//
//  Created by fanyi on 2019/8/16.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>

#import "BJPAnswerSheetViewController.h"
#import "BJPAppearance.h"
#import "BJPAnswerSheetOptionCell.h"

static NSString * const cellReuseIdentifier = @"AnswerSheetOptionCell";

@interface BJPAnswerSheetViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) BJLAnswerSheet *answerSheet;

@property (nonatomic) UIView *contentView;
@property (nonatomic) UIView *topBar;

@property (nonatomic) UICollectionView *optionsView;

@property (nonatomic) UILabel *commentsLabel;

@property (nonatomic) UIView *answerView;
@property (nonatomic) UILabel *answerDescriptLabel;
@property (nonatomic) UILabel *answerLabel;
@property (nonatomic) UIButton *finishButton;
@property (nonatomic) UIButton *submitButton;

@property (nonatomic, readonly) CGFloat optionButtonWH;
@property (nonatomic, readonly) CGFloat optionCountForRow;

@end

@implementation BJPAnswerSheetViewController

- (instancetype)initWithAnswerSheet:(BJLAnswerSheet *)answerSheet {
    self = [super init];
    if (self) {
        self.answerSheet = answerSheet;
        self->_optionButtonWH = (answerSheet.answerType == BJLAnswerSheetType_Judgement) ? 64.0 : 40.0;
        self->_optionCountForRow = (answerSheet.answerType == BJLAnswerSheetType_Judgement) ? 2 : 4;
        
        [self setupSubViews];
        [self checkSubmitButtonEnable];
    }
    return self;
}

- (void)dealloc {
    self.optionsView.delegate = nil;
    self.optionsView.dataSource = nil;
}

#pragma mark - subViews

- (void)setupSubViews {
    self.view.backgroundColor = [UIColor clearColor];
    // contentView
    [self.view addSubview:self.contentView];
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.view).priorityHigh(); // to update
        make.centerY.equalTo(self.view).multipliedBy(1.2).priorityHigh(); // to update
        make.width.equalTo(@(240.0)); // 指定宽度，高度自动计算
        // 边界限制
        make.top.left.greaterThanOrEqualTo(self.view);
        make.bottom.right.lessThanOrEqualTo(self.view);
    }];
    
    // top bar
    [self.contentView addSubview:self.topBar];
    [self.topBar bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.equalTo(@(30.0));
    }];
    [self setUpTopBar];
    
    // options view
    CGFloat optionsViewHeight = (self.answerSheet.options.count <= _optionCountForRow
                                 ? _optionButtonWH
                                 : _optionButtonWH * 2 + 15.0); // 1~2 行选项
    [self.contentView addSubview:self.optionsView];
    [self.optionsView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.topBar.bjl_bottom).offset(18.0);
        make.left.equalTo(self.contentView).offset(15.0);
        make.right.equalTo(self.contentView).offset(-15.0);
        make.height.equalTo(@(optionsViewHeight));
    }];
    
    [self.contentView addSubview:self.commentsLabel];
    
    CGFloat height = [self.commentsLabel sizeThatFits:CGSizeMake(210, 0.0)].height;
    [self.commentsLabel bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.top.equalTo(self.optionsView.bjl_bottom).offset(12.0);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(height + BJPViewSpaceS));
    }];

    // correct answer view
    [self.contentView addSubview:self.answerView];
    [self.answerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.commentsLabel.bjl_bottom).offset(12.0);
        make.left.equalTo(self.contentView).offset(15.0);
        make.right.equalTo(self.contentView).offset(-15.0);
        make.height.equalTo(@(30.0)); // to update
    }];
    [self setupAnswerView];
    
    // submit button
    [self.contentView addSubview:self.submitButton];
    [self.submitButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.answerView.bjl_bottom).offset(15.0);
        make.centerX.equalTo(self.contentView);
        make.size.equal.sizeOffset(CGSizeMake(196.0, 40.0));
        make.bottom.equalTo(self.contentView).offset(-15.0);
    }];
    
    // finish button
    [self.contentView addSubview:self.finishButton];
    [self.finishButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.submitButton);
    }];
}

- (void)setUpTopBar {
    // title label
    UILabel *titleLabel = [self labelWithTitle:@"答题器" color:[UIColor whiteColor]];
    [self.topBar addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.topBar).offset(10.0);
        make.centerY.equalTo(self.topBar);
    }];
    
    // close button
    UIButton *closeButton = ({
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage bjp_imageNamed:@"bjp_answer_close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.topBar addSubview:closeButton];
    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.topBar).offset(-10.0);
        make.top.bottom.equalTo(self.topBar);
    }];
}

- (void)setupAnswerView {
    // descript label
    [self.answerView addSubview:self.answerDescriptLabel];
    [self.answerDescriptLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.answerView).offset(7.5);
        make.centerY.equalTo(self.answerView);
    }];
    
    // answer label
    [self.answerView addSubview:self.answerLabel];
    [self.answerLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.answerView).offset(-7.5);
        make.centerY.equalTo(self.answerView);
    }];
}

#pragma mark - action

- (void)closeButtonOnClick:(UIButton *)button {
    [self close];
}

- (void)checkSubmitButtonEnable {
    BOOL enable = NO;
    for (BJLAnswerSheetOption *option in self.answerSheet.options) {
        if (option.selected) {
            enable = YES;
            break;
        }
    }
    
    self.submitButton.enabled = enable;
    self.submitButton.backgroundColor = [UIColor bjl_colorWithHexString:enable ? @"#1694FF" : @"#D7D7D7"];
}

- (void)submitButtonOnClick:(UIButton *)button {
    // 提交之后不允许再修改答案
    self.optionsView.userInteractionEnabled = NO;

    if (self.submitCallback) {
        self.submitCallback(self.answerSheet);
        // 隐藏提交按钮
        self.submitButton.hidden = YES;
        // 显示确定按钮
        self.finishButton.hidden = NO;
    }
}

- (void)finishButtonOnClick:(UIButton *)button {
    [self close];
}

- (void)close {
    if (self.closeCallback) {
        self.closeCallback();
    }
}

- (void)showSelectedAnswers {
    NSString *answerString = @"";
    for (BJLAnswerSheetOption *option in self.answerSheet.options) {
        if (option.key.length && option.selected) {
            answerString = [answerString stringByAppendingString:option.key];
        }
    }
    self.answerLabel.text = answerString;
}

#pragma mark - touch & move

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != self.topBar) {
        return;
    }
    
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.view];
    // 上一个触摸点
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    // 更新偏移量: 需要注意的是 self.contentView 的 centerY 默认是 self.view 的 contentY 的 1.2 倍
    CGFloat offsetX = (self.contentView.center.x - self.view.center.x) + (currentPoint.x - previousPoint.x);
    CGFloat offsetY = (self.contentView.center.y - self.view.center.y*1.2) + (currentPoint.y - previousPoint.y);
    
    // 修改当前 contentView 的中点
    [self.contentView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(offsetX).priorityHigh();
        make.centerY.equalTo(self.view).multipliedBy(1.2).offset(offsetY).priorityHigh();
    }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.answerSheet.options.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLAnswerSheetOption *option = [[self.answerSheet.options bjl_objectAtIndex:indexPath.row] bjl_as:[BJLAnswerSheetOption class]];
    BJPAnswerSheetOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [cell updateContentWithOptionKey:option.key isSelected:option.selected];
    bjl_weakify(self);
    [cell setOptionSelectedCallback:^(BOOL selected) {
        bjl_strongify(self);
        if (self.answerSheet.answerType == BJLAnswerSheetType_Judgement) {
            // 判断题只能选择一个答案
            for (BJLAnswerSheetOption *option in self.answerSheet.options) {
                option.selected = NO;
            }
        }
        option.selected = selected;
        [self checkSubmitButtonEnable];
        [self showSelectedAnswers];
        [collectionView reloadData];
    }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat combinedItemWidth = (_optionCountForRow * _optionButtonWH) + ((_optionCountForRow - 1) * 15.0);
    CGFloat padding = (collectionView.frame.size.width - combinedItemWidth) / 2;
    padding = MAX(0, padding);
    return UIEdgeInsetsMake(0, padding,0, padding);
}

#pragma mark - getters

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view.clipsToBounds = YES;
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 4.5;
            view;
        });
    }
    return _contentView;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [self blueColor];
            view;
        });
    }
    return _topBar;
}

-  (UICollectionView *)optionsView {
    if (!_optionsView) {
        _optionsView = ({
            // layout
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsZero;
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = CGSizeMake(_optionButtonWH, _optionButtonWH);
            
            // view
            UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            view.backgroundColor = [UIColor clearColor];
            view.showsHorizontalScrollIndicator = NO;
            view.bounces = NO;
            view.alwaysBounceVertical = YES;
            view.pagingEnabled = YES;
            view.dataSource = self;
            view.delegate = self;
            [view registerClass:[BJPAnswerSheetOptionCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            view;
        });
    }
    return _optionsView;
}

- (UILabel *)commentsLabel {
    if (!_commentsLabel) {
        _commentsLabel = [self labelWithTitle:@"" color:[self grayTextColor]];
        _commentsLabel.accessibilityLabel = BJLKeypath(self, commentsLabel);
        _commentsLabel.text = self.answerSheet.questionDescription;
        _commentsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _commentsLabel;
}

- (UIView *)answerView {
    if (!_answerView) {
        _answerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [self grayBackgroundColor];
            view.clipsToBounds = YES;
            view;
        });
    }
    return _answerView;
}

- (UILabel *)answerDescriptLabel {
    if (!_answerDescriptLabel) {
        _answerDescriptLabel = [self labelWithTitle:@"已选" color:[self grayTextColor]];
    }
    return _answerDescriptLabel;
}

- (UILabel *)answerLabel {
    if (!_answerLabel) {
        _answerLabel = [self labelWithTitle:@"" color:[self blueColor]];
    }
    return _answerLabel;
}

-  (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = ({
            UIButton *button = [self buttonWithTitle:@"确定"];
            [button addTarget:self action:@selector(finishButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [self blueColor];
            button.hidden = YES;
            button;
        });
    }
    return _finishButton;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [self buttonWithTitle:@"提交答案"];
        [_submitButton addTarget:self action:@selector(submitButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

#pragma mark - private

- (UILabel *)labelWithTitle:(NSString *)title color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:11.0];
    label.text = title;
    return label;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    int hours = interval / 3600;
    int minums = ((long long)interval % 3600) / 60;
    int seconds = (long long)interval % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minums, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d", minums, seconds];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 2.0;
    button.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (UIColor *)grayTextColor {
    return [UIColor bjl_colorWithHexString:@"#666666"];
}

- (UIColor *)grayBackgroundColor {
    return [UIColor bjl_colorWithHexString:@"#FAFAFA"];
}

- (UIColor *)blueColor {
    return [UIColor bjl_colorWithHexString:@"#1694FF"];
}

@end
