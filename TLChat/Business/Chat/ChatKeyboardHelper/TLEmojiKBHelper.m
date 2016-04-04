//
//  TLEmojiKBHelper.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/20.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLEmojiKBHelper.h"
#import "TLEmojiGroup.h"

static TLEmojiKBHelper *helper;

@interface TLEmojiKBHelper ()

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSMutableArray *emojiGroupData;

@property (nonatomic, strong) NSMutableArray *userProfectData;

@property (nonatomic, strong) NSMutableArray *defaultEmojiGroups;

@property (nonatomic, strong) NSMutableArray *userEmojiGroups;

@property (nonatomic, strong) NSMutableArray *systemEmojiGroups;

@end

@implementation TLEmojiKBHelper

+ (TLEmojiKBHelper *)sharedKBHelper
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        helper = [[TLEmojiKBHelper alloc] init];
    });
    return helper;
}

+ (NSMutableArray *)getEmojiDataByPath:(NSString *)path
{
    if (path == nil) {
        return nil;
    }
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSArray *array = [TLEmoji mj_objectArrayWithKeyValuesArray:jsonArray];
    return [NSMutableArray arrayWithArray:array];
}

- (void)emojiGroupDataByUserID:(NSString *)userID complete:(void (^)(NSMutableArray *))complete
{
    if (self.userID && [self.userID isEqualToString:userID] && self.emojiGroupData) {
        complete(self.emojiGroupData);
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.userID = userID;
        
        self.emojiGroupData = [[NSMutableArray alloc] init];
        
        // 默认表情包
        [self.emojiGroupData addObject:self.defaultEmojiGroups];
        
        // 用户收藏的表情包
        NSMutableArray *profectGroups = [self p_userProfectEmojiGroups];
        if (profectGroups && profectGroups.count > 0) {
            [self.emojiGroupData addObject:profectGroups];
        }
        
        // 用户的表情包
        NSMutableArray *userGroups = [self userEmojiGroupsByUserID:userID];
        if (userGroups && userGroups.count > 0) {
            [self.emojiGroupData addObject:userGroups];
        }
        
        // 系统设置
        [self.emojiGroupData addObject:self.systemEmojiGroups];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(self.emojiGroupData);
        });
    });
}

- (NSMutableArray *)userEmojiGroupsByUserID:(NSString *)userID
{
    // 兔斯基
    TLEmojiGroup *tisijiGroup = [[TLEmojiGroup alloc] init];
    tisijiGroup.type = TLEmojiTypeImage;
    tisijiGroup.groupName = @"兔斯基";
    tisijiGroup.groupIconPath = @"emojiKB_group_tusiji";
    tisijiGroup.path = [[NSBundle mainBundle] pathForResource:@"TusijiEmoji" ofType:@"json"];
    
    TLEmojiGroup *group2 = [[TLEmojiGroup alloc] init];
    group2.type = TLEmojiTypeImageWithTitle;
    group2.groupName = @"老司机";
    group2.groupIconPath = @"emojiKB_group_tusiji";
    group2.path = [[NSBundle mainBundle] pathForResource:@"TusijiTitleEmoji" ofType:@"json"];
    
    NSMutableArray *userEmojiGroupData = [[NSMutableArray alloc] initWithObjects:tisijiGroup, group2, nil];
    return userEmojiGroupData;
}

#pragma mark - Private Methods -
- (NSMutableArray *)p_userProfectEmojiGroups
{
    return nil;
}

#pragma mark - Getter -
- (TLEmojiGroup *)defaultFaceGroup
{
    if (_defaultFaceGroup == nil) {
        _defaultFaceGroup = [[TLEmojiGroup alloc] init];
        _defaultFaceGroup.type = TLEmojiTypeFace;
        _defaultFaceGroup.groupIconPath = @"emojiKB_group_face";
        _defaultFaceGroup.path = [[NSBundle mainBundle] pathForResource:@"FaceEmoji" ofType:@"json"];
    }
    return _defaultFaceGroup;
}

- (NSMutableArray *)defaultEmojiGroups
{
    if (_defaultEmojiGroups == nil) {
        TLEmojiGroup *emojiGroup = [[TLEmojiGroup alloc] init];
        emojiGroup.type = TLEmojiTypeEmoji;
        emojiGroup.groupIconPath = @"emojiKB_group_face";
        emojiGroup.path = [[NSBundle mainBundle] pathForResource:@"SystemEmoji" ofType:@"json"];
        
        
        _defaultEmojiGroups = [[NSMutableArray alloc] initWithObjects:self.defaultFaceGroup, emojiGroup, nil];
    }
    return _defaultEmojiGroups;
}

- (NSMutableArray *)systemEmojiGroups
{
    if (_systemEmojiGroups == nil) {
        TLEmojiGroup *editGroup = [[TLEmojiGroup alloc] init];
        editGroup.type = TLEmojiTypeOther;
        editGroup.groupIconPath = @"emojiKB_settingBtn";
        _systemEmojiGroups = [[NSMutableArray alloc] initWithObjects:editGroup, nil];
    }
    return _systemEmojiGroups;
}

@end
