//
//  TLChatBaseViewController.h
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMoreKeyboardDelegate.h"
#import "TLEmojiKeyboardDataSource.h"

#import "TLChatBar.h"
#import "TLMoreKeyboard.h"
#import "TLEmojiKeyboard.h"

#import "TLUser.h"
#import "TLGroup.h"

@interface TLChatBaseViewController : UIViewController <TLMoreKeyboardDelegate, TLEmojiKeyboardDataSource>

@property (nonatomic, strong) TLUser *user;

@property (nonatomic, strong) TLGroup *group;

/// 聊天数据
@property (nonatomic, strong) NSMutableArray *data;

/// UI
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TLChatBar *chatBar;

@property (nonatomic, strong) TLMoreKeyboard *moreKeyboard;

@property (nonatomic, strong) TLEmojiKeyboard *emojiKeyboard;


/**
 *  设置“更多”键盘元素
 */
- (void)setChatMoreKeyboardData:(NSMutableArray *)moreKeyboardData;

/**
 *  设置“表情”键盘元素
 */
- (void)setChatEmojiKeyboardData:(NSMutableArray *)emojiKeyboardData;

/**
 *  发送图片信息
 */
- (void)sendImageMessage:(NSString *)imagePath;

@end
