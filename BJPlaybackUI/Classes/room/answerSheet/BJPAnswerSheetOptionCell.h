//
//  BJPAnswerSheetOptionCell.h
//  BJPlaybackUI
//
//  Created by fanyi on 2019/8/16.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPAnswerSheetOptionCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^optionSelectedCallback)(BOOL selected);

- (void)updateContentWithOptionKey:(NSString *)optionKey isSelected:(BOOL)isSelected;

- (void)updateContentWithSelectedKey:(NSString *)optionKey isCorrect:(BOOL)isCorrect;

@end

NS_ASSUME_NONNULL_END
