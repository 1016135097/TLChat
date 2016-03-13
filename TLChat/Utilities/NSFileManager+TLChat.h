//
//  NSFileManager+TLChat.h
//  TLChat
//
//  Created by 李伯坤 on 16/3/3.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+Paths.h"

@interface NSFileManager (TLChat)

+ (NSString *)pathUserSettingImage:(NSString *)imageName forUser:(NSString *)userID;

+ (NSString *)pathUserChatImage:(NSString*)imageName forUser:(NSString *)userID;

+ (NSString *)pathUserChatAvatar:(NSString *)imageName forUser:(NSString *)userID;

+ (NSString *)pathScreenshotImage:(NSString *)imageName;

+ (NSString *)pathContactsAvatar:(NSString *)imageName;

+ (NSString *)pathDBCommonForUser:(NSString *)userID;

+ (NSString *)pathDBMessageForUser:(NSString *)userID;

@end
