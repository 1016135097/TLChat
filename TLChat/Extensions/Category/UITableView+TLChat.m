
//
//  UITableView+TLChat.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/18.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "UITableView+TLChat.h"

@implementation UITableView (TLChat)

- (void)scrollToBottomWithAnimation:(BOOL)animation
{
    NSUInteger section = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        section = [self.dataSource numberOfSectionsInTableView:self] - 1;
    }
    if ([self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        NSUInteger row = [self.dataSource tableView:self numberOfRowsInSection:section];
        if (row > 0) {
            [self selectRowAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:section] animated:animation scrollPosition:UITableViewScrollPositionBottom];
        }
    }
}

@end
