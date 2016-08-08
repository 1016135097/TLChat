//
//  TLEmojiKeyboard.h
//  TLChat
//
//  Created by 李伯坤 on 16/2/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLBaseKeyboard.h"
#import "TLKeyboardDelegate.h"
#import "TLEmojiKeyboardDelegate.h"
#import "TLEmojiGroupControl.h"

@interface TLEmojiKeyboard : TLBaseKeyboard
{
    CGSize cellSize;
    CGFloat minimumLineSpacing;
    CGFloat minimumInteritemSpacing;
    UIEdgeInsets sectionInsets;
}

@property (nonatomic, assign) NSMutableArray *emojiGroupData;

@property (nonatomic, assign) id<TLEmojiKeyboardDelegate> delegate;

@property (nonatomic, strong) TLEmojiGroup *curGroup;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) TLEmojiGroupControl *groupControl;

+ (TLEmojiKeyboard *)keyboard;

@end
