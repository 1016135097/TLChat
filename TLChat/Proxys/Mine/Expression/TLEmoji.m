//
//  TLEmoji.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/20.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLEmoji.h"

@implementation TLEmoji

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"emojiID" : @"eId",
             @"emojiURL" : @"Url",
             @"emojiName" : @"credentialName",
             @"emojiPath" : @"imageFile",
             @"size" : @"size",
             };
}

@end
