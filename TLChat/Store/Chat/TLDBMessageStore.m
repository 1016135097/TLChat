//
//  TLDBMessageStore.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/13.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLDBMessageStore.h"
#import "TLDBMessageStoreSQL.h"
#import "TLDBMessage+TLMessage.h"
#import "NSDate+Utilities.h"

@implementation TLDBMessageStore

- (id)init
{
    if (self = [super init]) {
        self.dbQueue = [TLDBManager sharedInstance].messageQueue;
        BOOL ok = [self createTable];
        if (!ok) {
            DDLogError(@"DB: 聊天记录表创建失败");
        }
    }
    return self;
}

- (BOOL)createTable
{
    NSString *sqlString = [NSString stringWithFormat:SQL_CREATE_TABLE, MESSAGE_TABLE_NAME];
    return [self createTable:MESSAGE_TABLE_NAME withSQL:sqlString];
}

- (BOOL)addMessage:(TLMessage *)message
{
    TLDBMessage *dbMessage = [message toDBMessage];
    if (dbMessage.mid == nil || dbMessage.uid == nil || dbMessage.fid == nil) {
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:SQL_ADD_MESSAGE, MESSAGE_TABLE_NAME];
    NSArray *arrPara = [NSArray arrayWithObjects:
                        dbMessage.mid,
                        dbMessage.uid,
                        dbMessage.fid,
                        dbMessage.subfid.length > 0 ? dbMessage.subfid : @"",
                        dbMessage.date,
                        [NSNumber numberWithInteger:dbMessage.partnerType],
                        [NSNumber numberWithInteger:dbMessage.ownerType],
                        [NSNumber numberWithInteger:dbMessage.msgType],
                        dbMessage.content,
                        [NSNumber numberWithInteger:dbMessage.sendStatus],
                        [NSNumber numberWithInteger:dbMessage.receivedStatus],
                        dbMessage.ext1.length > 0 ? dbMessage.ext1 : @"",
                        dbMessage.ext2.length > 0 ? dbMessage.ext2 : @"",
                        dbMessage.ext3.length > 0 ? dbMessage.ext3 : @"",
                        dbMessage.ext4.length > 0 ? dbMessage.ext4 : @"",
                        dbMessage.ext5.length > 0 ? dbMessage.ext5 : @"",
                        nil];
    BOOL ok = [self excuteSQL:sqlString withArrParameter:arrPara];
    return ok;
}

- (void)messagesByUserID:(NSString *)userID partnerID:(NSString *)partnerID fromDate:(NSDate *)date count:(NSUInteger)count complete:(void (^)(NSArray *, BOOL))complete
{
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    NSString *sqlstr = [NSString stringWithFormat:
                        SQL_SELECT_MESSAGES_PAGE,
                        MESSAGE_TABLE_NAME,
                        userID,
                        partnerID,
                        [NSString stringWithFormat:@"%lf", date.timeIntervalSince1970],
                        count + 1];

    [self excuteQuerySQL:sqlstr resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            TLDBMessage *dbMessage = [self p_createDBMessageByFMResultSet:retSet];
            TLMessage *message = [dbMessage toMessage];
            [data insertObject:message atIndex:0];
        }
        [retSet close];
    }];
    
    BOOL hasMore = NO;
    if (data.count == count + 1) {
        hasMore = YES;
        [data removeObjectAtIndex:0];
    }
    complete(data, hasMore);
}

- (NSArray *)chatFilesByUserID:(NSString *)userID partnerID:(NSString *)partnerID
{
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:SQL_SELECT_CHAT_FILES, MESSAGE_TABLE_NAME, userID, partnerID];
    
    __block NSDate *lastDate = [NSDate date];
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            TLDBMessage *dbMessage = [self p_createDBMessageByFMResultSet:retSet];
            TLMessage *message = [dbMessage toMessage];
            if ([message.date isThisWeek]) {
                if ([lastDate isThisWeek]) {
                    [array addObject:message];
                }
                else {
                    lastDate = message.date;
                    array = [[NSMutableArray alloc] initWithObjects:lastDate, nil];
                }
            }
            else {
                if ([lastDate isSameMonthAsDate:message.date]) {
                    [array addObject:message];
                }
                else {
                    lastDate = message.date;
                    array = [[NSMutableArray alloc] initWithObjects:lastDate, nil];
                }
            }
        }
        if (array.count > 0) {
            [data insertObject:array atIndex:0];
        }
        [retSet close];
    }];
    return data;
}

- (BOOL)deleteMessageByMessageID:(NSString *)messageID
{
    NSString *sqlString = [NSString stringWithFormat:SQL_DELETE_MESSAGE, MESSAGE_TABLE_NAME, messageID];
    BOOL ok = [self excuteSQL:sqlString, nil];
    return ok;
}

- (BOOL)deleteMessagesByUserID:(NSString *)userID partnerID:(NSString *)partnerID;
{
    NSString *sqlString = [NSString stringWithFormat:SQL_DELETE_FRIEND_MESSAGES, MESSAGE_TABLE_NAME, userID, partnerID];
    BOOL ok = [self excuteSQL:sqlString, nil];
    return ok;
}

- (BOOL)deleteMessagesByUserID:(NSString *)userID
{
    NSString *sqlString = [NSString stringWithFormat:SQL_DELETE_USER_MESSAGES, MESSAGE_TABLE_NAME, userID];
    BOOL ok = [self excuteSQL:sqlString, nil];
    return ok;
}

#pragma mark - Private Methods -
- (TLDBMessage *)p_createDBMessageByFMResultSet:(FMResultSet *)retSet
{
    TLDBMessage *dbMessage = [[TLDBMessage alloc]init];
    dbMessage.mid = [retSet stringForColumn:@"msgid"];
    dbMessage.uid = [retSet stringForColumn:@"uid"];
    dbMessage.fid = [retSet stringForColumn:@"fid"];
    dbMessage.subfid = [retSet stringForColumn:@"subfid"];
    dbMessage.date = [retSet stringForColumn:@"date"];
    dbMessage.partnerType = [retSet intForColumn:@"partner_type"];
    dbMessage.ownerType = [retSet intForColumn:@"own_type"];
    dbMessage.msgType = [retSet intForColumn:@"msg_type"];
    dbMessage.content = [retSet stringForColumn:@"content"];
    dbMessage.sendStatus = [retSet intForColumn:@"send_status"];
    dbMessage.receivedStatus = [retSet intForColumn:@"received_status"];
    dbMessage.ext1 = [retSet stringForColumn:@"ext1"];
    dbMessage.ext2 = [retSet stringForColumn:@"ext2"];
    dbMessage.ext3 = [retSet stringForColumn:@"ext3"];
    dbMessage.ext4 = [retSet stringForColumn:@"ext4"];
    dbMessage.ext5 = [retSet stringForColumn:@"ext5"];
    return dbMessage;
}

@end
