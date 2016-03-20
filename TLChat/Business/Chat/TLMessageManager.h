//
//  TLMessageManager.h
//  TLChat
//
//  Created by 李伯坤 on 16/3/13.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLDBMessageStore.h"
#import "TLMessage.h"

@interface TLMessageManager : NSObject

@property (nonatomic, strong) TLDBMessageStore *messageStore;

+ (TLMessageManager *)sharedInstance;

#pragma mark - 发送
- (void)sendMessage:(TLMessage *)message
           progress:(void (^)(TLMessage *, CGFloat))progress
            success:(void (^)(TLMessage *))success
            failure:(void (^)(TLMessage *))failure;


@end
