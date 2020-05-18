//
//  BJPlaybackUI.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/9/15.
//
//

#import "BJPlaybackUI.h"

NSString * BJPlaybackUIName() {
    return BJLStringFromPreprocessor(BJPLAYBACKUI_NAME, @"BJPlaybackUI");
}
NSString * BJPlaybackUIVersion() {
    return BJLStringFromPreprocessor(BJPLAYBACKUI_VERSION, @"-");
}
