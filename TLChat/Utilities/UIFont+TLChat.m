//
//  UIFont+TLChat.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/27.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "UIFont+TLChat.h"

@implementation UIFont (TLChat)

+ (UIFont *) fontNavBarTitle
{
    return [UIFont boldSystemFontOfSize:17.5f];
}

+ (UIFont *) fontConversationUsername
{
    return [UIFont systemFontOfSize:16.0f];
}

+ (UIFont *) fontConversationDetail
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *) fontConversationTime
{
    return [UIFont systemFontOfSize:12.5f];
}

+ (UIFont *) fontFriendsUsername
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *) fontMineNikename
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *) fontMineUsername
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *) fontSettingHeaderAndFooterTitle
{
    return [UIFont systemFontOfSize:14.0f];
}

@end
