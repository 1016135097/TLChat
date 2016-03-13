//
//  TLDBManager.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/13.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLDBManager.h"

static TLDBManager *manager;

@implementation TLDBManager

+ (TLDBManager *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[TLDBManager alloc] init];
    });
    return manager;
}

- (id)init
{
    if (self = [super init]) {
        NSString *commonQueuePath;
        self.commonQueue = [FMDatabaseQueue databaseQueueWithPath:commonQueuePath];
        NSString *messageQueuePath;
        self.messageQueue = [FMDatabaseQueue databaseQueueWithPath:messageQueuePath];
    }
    return self;
}

@end
