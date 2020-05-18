//
//  BJPChatMessageTableViewCell.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#import <BJVideoPlayerCore/BJVRoom.h>

#import "BJPChatMessageTableViewCell.h"
#import "BJPAppearance.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const BJPMessageDefaultIdentifier = @"default";
static NSString * const BJPMessageEmoticonIdentifier = @"emoticon";
static NSString * const BJPMessageImageIdentifier = @"image";

static const CGFloat verMargins = (10.0 + 5.0 + 10.0) + 5.0; // last 5.0: bgView.top+bottom

static const CGFloat fontSize = 14.0;
static const CGFloat oneLineMessageCellHeight = fontSize + verMargins;

static const CGFloat emoticonSize = 32.0;
static const CGFloat emoticonMessageCellHeight = emoticonSize + verMargins;

static const CGFloat imageMinWidth = 50.0, imageMinHeight = 50.0;
static const CGFloat imageMaxWidth = 100.0, imageMaxHeight = 100.0;
static const CGFloat imageMessageCellMinHeight = imageMinHeight + verMargins;

@interface BJPChatMessageTableViewCell()

@property (nonatomic, readwrite) UIImageView *imgView;
@property (nonatomic) UILabel *nameLabel, *messageLabel;
@property (nonatomic) UIView *bgView;

@property (nonatomic) CGFloat tableViewWidth;

@end

@implementation BJPChatMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        [self setupConstraints];
        [self prepareForReuse];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    if (h > w) {
        self.bgView.backgroundColor = [UIColor bjp_lightGrayBackgroundColor];
        self.messageLabel.textColor = [UIColor bjp_darkGrayTextColor];
    }
    else {
        self.bgView.backgroundColor = [UIColor bjp_darkDimColor];
        self.messageLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setupSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.bgView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjp_lightGrayBackgroundColor];
        view.layer.cornerRadius = 5;
        view.layer.masksToBounds = YES;
        [self.contentView addSubview:view];
        view;
    });
    
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:fontSize];
        [self.bgView addSubview:label];
        label;
    });
    
    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textColor = [UIColor bjp_darkGrayTextColor];
        [self.bgView addSubview:label];
        label;
    });
    
    BOOL isEmoticon = [self.reuseIdentifier isEqualToString:BJPMessageEmoticonIdentifier];
    BOOL isImage = [self.reuseIdentifier isEqualToString:BJPMessageImageIdentifier];

    if (isEmoticon || isImage) {
        self.messageLabel.hidden = YES;
        
        self.imgView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.clipsToBounds = YES;
            imageView.contentMode = (isEmoticon
                                     ? UIViewContentModeScaleAspectFit
                                     : UIViewContentModeScaleAspectFill);
            [self.bgView addSubview:imageView];
            imageView;
        });

    }
}

- (void)setupConstraints {
    // <right>
    [self.bgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.horizontal.hugging.required();
        CGFloat spaceLeft = BJPScrollIndicatorSize, spaceBottom = 1.0, spaceTop = BJPViewSpaceS - spaceBottom;
        make.left.top.bottom.equalTo(self.contentView).insets(UIEdgeInsetsMake(spaceTop, spaceLeft, spaceBottom, 0.0));
        // <right>
        make.right.lessThanOrEqualTo(self.contentView).with.offset(self.imgView ? - (BJPBadgeSize + BJPViewSpaceS) : 0.0);
    }];
    
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.top.equalTo(self.bgView).offset(BJPViewSpaceM);
        // <right>
        make.right.equalTo(self.bgView).with.offset(- BJPViewSpaceM).priorityLow();
        make.right.lessThanOrEqualTo(self.bgView).with.offset(- BJPViewSpaceM);
//         make.height.equalTo(@(self.nameLabel.font.lineHeight));
    }];
    
    if (self.imgView) {
        if ([self.reuseIdentifier isEqualToString:BJPMessageEmoticonIdentifier]) {
            [self remakeImgViewConstraintsWithSize:CGSizeMake(emoticonSize, emoticonSize)];
        }
    }
    
        // else if BJLMessageImageIdentifier || BJLMessageUploadingImageIdentifier:
        // init/reset in prepareForReuse, and update in updateCell
    else {
        [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.bgView).with.offset(BJPViewSpaceM);
            // <right>
            make.right.equalTo(self.bgView).with.offset(- BJPViewSpaceM);
            make.top.equalTo(self.nameLabel.bjl_bottom).offset(BJPViewSpaceS);
            make.bottom.equalTo(self.bgView).with.offset(- BJPViewSpaceM);
            make.width.equalTo(@0.0).priorityHigh();
            make.height.equalTo(@0.0).priorityHigh();
        }];
    }

}

- (void)remakeImgViewConstraintsWithSize:(CGSize)size {
    [self.imgView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.bgView).with.offset(BJPViewSpaceM);
        // <right>
        make.right.equalTo(self.bgView).with.offset(- BJPViewSpaceM).priorityLow();
        make.right.lessThanOrEqualTo(self.bgView).with.offset(- BJPViewSpaceM).priorityMedium();
        
        make.top.equalTo(self.nameLabel.bjl_bottom).offset(BJPViewSpaceS);
        make.bottom.equalTo(self.bgView).with.offset(- BJPViewSpaceM);
        
        make.size.equal.sizeOffset(size).priorityHigh();
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.nameLabel.textColor = nil;
    self.messageLabel.text = nil;
    self.messageLabel.attributedText = nil;
    self.imgView.image = nil;
}

#pragma mark - private updating

- (void)_updateLabelsWithMessage:(BJLMessage *)message
                        fromUser:(BJVUser *)fromUser {
//    self.nameLabel.text = [fromUser.displayName ?: @"?" stringByAppendingString:@" "];
    NSString *teacherString = [NSString stringWithFormat:@"%@(老师):", fromUser.displayName ?: @"?"];
    NSString *otherString = [NSString stringWithFormat:@"%@:", fromUser.displayName ?: @"?"];
    self.nameLabel.text = fromUser.isTeacher ? teacherString : otherString;
    self.nameLabel.textColor = (fromUser.isTeacher // isTeacherOrAssistant
                                ? [UIColor bjp_blueBrandColor]
                                : [UIColor bjp_lightGrayTextColor]);
    BOOL horizontal = BJPIsHorizontalUI(self);
    if (message.text) {
        self.messageLabel.attributedText = [message attributedEmoticonStringWithEmoticonSize:fontSize + 4.0 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:(horizontal ? [UIColor whiteColor] : [UIColor bjp_darkGrayTextColor])} cached:YES cachedKey:(horizontal ? @"white" : @"gray")];
    }
    
    CGFloat maxContentWidth = self.tableViewWidth-BJPViewSpaceM*2-BJPScrollIndicatorSize;
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:CGSizeMake(maxContentWidth, 0)];
    CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(maxContentWidth, 0)];
    CGFloat messageWidth = MAX(nameLabelSize.width, messageLabelSize.width);
    [self.messageLabel bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(@(messageWidth)).priorityHigh();
        make.height.equalTo(@(messageLabelSize.height)).priorityHigh();
    }];
}

- (void)_updateImageViewWithImageOrNil:(nullable UIImage *)image {
    self.imgView.image = image;
    if (image) {
        
        
        [self remakeImgViewConstraintsWithSize:BJPImageViewSize(image.size, CGSizeMake(imageMinWidth, imageMinHeight), ({
            /*
             CGFloat imageMaxWidth = MAX(imageMinWidth, (self.tableViewWidth
             - BJLViewSpaceM * 2
             - BJLBadgeSize
             - BJLViewSpaceS));
             CGFloat imageMaxHeight = MAX(imageMinHeight, imageMaxWidth / 4 * 3);
             CGSizeMake(imageMaxWidth, imageMaxHeight); */
            CGSizeMake(imageMaxWidth, imageMaxHeight);
        }))];
    }
    else {
        [self remakeImgViewConstraintsWithSize:CGSizeMake(imageMinWidth, imageMinHeight)];
    }
}

- (void)_updateImageViewWithImageURLString:(NSString *)imageURLString placeholder:(UIImage *)placeholder {
    [self _updateImageViewWithImageOrNil:placeholder];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxSize = MAX(screenSize.width, screenSize.height);
    NSString *aliURLString = BJLAliIMG_aspectFit(CGSizeMake(maxSize, maxSize), 1.0, imageURLString, nil);
    bjl_weakify(self);
    self.imgView.backgroundColor = [UIColor bjp_grayImagePlaceholderColor];
    [self.imgView bjl_setImageWithURL:[NSURL URLWithString:aliURLString]
                          placeholder:placeholder
                           completion:^(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL) {
                               bjl_strongify(self);
                               if (image) {
                                   self.imgView.backgroundColor = [UIColor bjp_grayImagePlaceholderColor];
                               }
                               [self _updateImageViewWithImageOrNil:image];
                               if (self.updateCellConstraintsCallback) self.updateCellConstraintsCallback(self);
                           }];
}


#pragma mark - public updating

- (void)updateWithMessage:(__kindof BJLMessage *)message
              placeholder:(nullable UIImage *)placeholder
           tableViewWidth:(CGFloat)tableViewWidth {
    self.tableViewWidth = tableViewWidth;
    
    [self _updateLabelsWithMessage:message
                          fromUser:message.fromUser];
    
    if (message.type == BJLMessageType_emoticon) {
        if (message.emoticon.cachedImage) {
            self.imgView.image = message.emoticon.cachedImage;
        }
        else {
            NSString *urlString = message.emoticon.urlString.length ? BJLAliIMG_aspectFit(CGSizeMake(emoticonSize, emoticonSize), 1.0, message.emoticon.urlString, nil) : @"";
            bjl_weakify(self);
             self.imgView.backgroundColor = [UIColor bjp_grayImagePlaceholderColor];
            [self.imgView bjl_setImageWithURL:[NSURL URLWithString:urlString]
                                  placeholder:nil
                                   completion:^(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL) {
                                       bjl_strongify(self);
                                       if (image) {
                                           self.imgView.backgroundColor = nil;
                                           message.emoticon.cachedImage = image;
                                           self.imgView.image = image;
                                       }
                                   }];
        }
    }
    else if (message.type == BJLMessageType_image) {
        [self _updateImageViewWithImageURLString:message.imageURLString placeholder:placeholder];
    }
}

#pragma mark -

+ (NSArray<NSString *> *)allCellIdentifiers {
    return @[ BJPMessageDefaultIdentifier,
              BJPMessageEmoticonIdentifier,
              BJPMessageImageIdentifier ];
}

+ (NSString *)cellIdentifierForMessageType:(BJLMessageType)type {
    switch (type) {
        case BJLMessageType_emoticon:
            return BJPMessageEmoticonIdentifier;
        case BJLMessageType_image:
            return BJPMessageImageIdentifier;
        default:
            return BJPMessageDefaultIdentifier;
    }
}

+ (CGFloat)estimatedRowHeightForMessageType:(BJLMessageType)type {
    switch (type) {
        case BJLMessageType_emoticon:
            return emoticonMessageCellHeight;
        case BJLMessageType_image:
            return imageMessageCellMinHeight;
        default:
            return oneLineMessageCellHeight;
    }
}


@end

NS_ASSUME_NONNULL_END
