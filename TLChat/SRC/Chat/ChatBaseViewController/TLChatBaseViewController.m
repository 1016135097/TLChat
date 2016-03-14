//
//  TLChatBaseViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBaseViewController.h"
#import "TLChatKeyboardController.h"
#import "TLFriendHelper.h"

#define     MAX_SHOWTIME_MSG_COUNT      10
#define     MAX_SHOWTIME_MSG_SECOND     30

@interface TLChatBaseViewController () <TLChatBarDataDelegate, TLChatTableViewControllerDelegate>

@property (nonatomic, strong) TLChatKeyboardController *chatKeyboardController;

@end

@implementation TLChatBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.chatTableVC.tableView];
    [self addChildViewController:self.chatTableVC];
    [self.view addSubview:self.chatBar];
    
    [self p_addMasonry];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.chatKeyboardController setChatBaseVC:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.chatKeyboardController selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.chatKeyboardController selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.chatKeyboardController selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public Methods -
- (void)setUser:(TLUser *)user
{
    if (_curChatType != TLChatVCTypeFriend || !_user || ![_user.userID isEqualToString:user.userID]) {
        _user = user;
        [self.navigationItem setTitle:user.showName];
        _curChatType = TLChatVCTypeFriend;
        _group = nil;
        [self p_resetChatVC];
    }
}

- (void)setGroup:(TLGroup *)group
{
    if (_curChatType != TLChatVCTypeGroup || !_group || [_group.groupID isEqualToString:group.groupID]) {
        _group = group;
        [self.navigationItem setTitle:group.groupName];
        _curChatType = TLChatVCTypeGroup;
        _user = nil;
        [self p_resetChatVC];
    }
}

- (void)setChatMoreKeyboardData:(NSMutableArray *)moreKeyboardData
{
    [self.moreKeyboard setChatMoreKeyboardData:moreKeyboardData];
}

- (void)setChatEmojiKeyboardData:(NSMutableArray *)emojiKeyboardData
{
    [self.emojiKeyboard setEmojiGroupData:emojiKeyboardData];
}

/**
 *  发送图片消息
 */
- (void)sendImageMessage:(UIImage *)image
{
    NSData *imageData = (UIImagePNGRepresentation(image) ? UIImagePNGRepresentation(image) :UIImageJPEGRepresentation(image, 0.5));
    NSString *imageName = [NSString stringWithFormat:@"%lf.jpg", [NSDate date].timeIntervalSince1970];
    NSString *imagePath = [NSFileManager pathUserChatAvatar:imageName forUser:[TLUserHelper sharedHelper].userID];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TLMessage *message = [[TLMessage alloc] init];
    message.fromUser = [TLUserHelper sharedHelper].user;
    message.messageType = TLMessageTypeImage;
    message.ownerTyper = TLMessageOwnerTypeSelf;
    message.imagePath = imageName;
    message.showName = NO;
    [self p_sendMessage:message];
    if (self.curChatType == TLChatVCTypeFriend) {
        TLMessage *message1 = [[TLMessage alloc] init];
        message1.fromUser = self.user;
        message1.messageType = TLMessageTypeImage;
        message1.ownerTyper = TLMessageOwnerTypeFriend;
        message1.imagePath = imagePath;
        message1.showName = NO;
        [self p_sendMessage:message1];
    }
    else {
        for (TLUser *user in self.group.users) {
            TLMessage *message1 = [[TLMessage alloc] init];
            message1.friendID = user.userID;
            message1.fromUser = user;
            message1.messageType = TLMessageTypeImage;
            message1.ownerTyper = TLMessageOwnerTypeFriend;
            message1.imagePath = imageName;
            message1.showName = NO;
            [self p_sendMessage:message1];
        }
    }
}

#pragma mark - Delegate -
//MARK: TLChatTableViewControllerDelegate
- (void)chatTableViewControllerDidTouched:(TLChatTableViewController *)chatTVC
{
    if ([self.chatBar isFirstResponder]) {
        [self.chatBar resignFirstResponder];
    }
}

/**
 *  获取历史记录
 */
- (void)chatRecordsFromDate:(NSDate *)date count:(NSUInteger)count completed:(void (^)(NSDate *, NSArray *, BOOL))completed
{
    NSString *partnerID;
    if (self.curChatType == TLPartnerTypeGroup) {
        partnerID = self.group.groupID;
    }
    else {
        partnerID = self.user.userID;
    }
    [self.messageManager messageRecordForUser:[TLUserHelper sharedHelper].userID andPartner:partnerID fromDate:date count:count complete:^(NSArray *array, BOOL hasMore) {
        if (array.count > 0) {
            int count = 0;
            NSTimeInterval tm = 0;
            for (TLMessage *message in array) {
                if (++count > MAX_SHOWTIME_MSG_COUNT || tm == 0 || message.date.timeIntervalSince1970 - tm > MAX_SHOWTIME_MSG_SECOND) {
                    tm = message.date.timeIntervalSince1970;
                    count = 0;
                    message.showTime = YES;
                }
                if (message.ownerTyper == TLMessageOwnerTypeSelf) {
                    message.fromUser = [TLUserHelper sharedHelper].user;
                }
                else {
                    if (self.curChatType == TLPartnerTypeUser) {
                        message.fromUser = self.user;
                    }
                    else {
                        message.fromUser = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:message.friendID];
                    }
                }
            }
        }
        completed(date, array, hasMore);
    }];
}

//MARK: TLChatBarDataDelegate
/**
 *  发送文字消息
 */
- (void)chatBar:(TLChatBar *)chatBar sendText:(NSString *)text
{
    TLMessage *message = [[TLMessage alloc] init];
    message.fromUser = [TLUserHelper sharedHelper].user;
    message.messageType = TLMessageTypeText;
    message.ownerTyper = TLMessageOwnerTypeSelf;
    message.text = text;
    message.showName = NO;
    [self p_sendMessage:message];
    if (self.curChatType == TLChatVCTypeFriend) {
        TLMessage *message1 = [[TLMessage alloc] init];
        message1.fromUser = self.user;
        message1.messageType = TLMessageTypeText;
        message1.ownerTyper = TLMessageOwnerTypeFriend;
        message1.text = text;
        message1.showName = NO;
        [self p_sendMessage:message1];
    }
    else {
        for (TLUser *user in self.group.users) {
            TLMessage *message1 = [[TLMessage alloc] init];
            message1.friendID = user.userID;
            message1.fromUser = user;
            message1.messageType = TLMessageTypeText;
            message1.ownerTyper = TLMessageOwnerTypeFriend;
            message1.text = text;
            message1.showName = NO;
            [self p_sendMessage:message1];
        }
    }
}

//MARK: TLEmojiKeyboardDelegate
- (void)sendButtonDown
{
    [self.chatBar sendCurrentText];
}

- (void)touchInEmojiItem:(TLEmoji *)emoji point:(CGPoint)point
{
    NSLog(@"touch in %@, path %@", emoji.title, emoji.path);
}

- (void)cancelTouchEmojiItem
{
    NSLog(@"cancel touch");
}

- (BOOL)chatInputViewHasText
{
    return self.chatBar.curText.length == 0 ? NO : YES;
}

#pragma mark - Private Methods -
/**
 *  发送消息（网络、数据库）
 */
- (void)p_sendMessage:(TLMessage *)message
{
    message.userID = [TLUserHelper sharedHelper].userID;
    if (self.curChatType == TLChatVCTypeFriend) {
        message.partnerType = TLPartnerTypeUser;
        message.friendID = self.user.userID;
    }
    else if (self.curChatType == TLChatVCTypeGroup) {
        message.partnerType = TLPartnerTypeGroup;
        message.groupID = self.group.groupID;
    }
//    message.ownerTyper = TLMessageOwnerTypeSelf;
//    message.fromUser = [TLUserHelper sharedHelper].user;
    message.date = [NSDate date];
//    message.showName = NO;
    
    [self p_addMessage:message];    // 添加到列表
    [self.messageManager sendMessage:message progress:^(TLMessage *message, CGFloat pregress) {
        
    } success:^(TLMessage *message) {
        NSLog(@"send success");
    } failure:^(TLMessage *message) {
        NSLog(@"send failure");
    }];
}

/**
 *  展示消息（添加到chatVC）
 */
- (void)p_addMessage:(TLMessage *)message
{
    message.showTime = [self p_needShowTime:message.date];
    [self.chatTableVC addMessage:message];
    [self.chatTableVC scrollToBottomWithAnimation:YES];
}

/**
 *  重置chatVC，清空数据
 */
- (void)p_resetChatVC
{
    [self.chatTableVC reloadData];
    lastDateInterval = 0;
    msgAccumulate = 0;
}

static NSTimeInterval lastDateInterval = 0;
static NSInteger msgAccumulate = 0;
- (BOOL)p_needShowTime:(NSDate *)date
{
    if (++msgAccumulate > MAX_SHOWTIME_MSG_COUNT || lastDateInterval == 0 || date.timeIntervalSince1970 - lastDateInterval > MAX_SHOWTIME_MSG_SECOND) {
        lastDateInterval = date.timeIntervalSince1970;
        msgAccumulate = 0;
        return YES;
    }
    return NO;
}

- (void)p_addMasonry
{
    [self.chatTableVC.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.chatBar.mas_top);
    }];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - Getter -
- (TLMessageManager *)messageManager
{
    if (_messageManager == nil) {
        _messageManager = [[TLMessageManager alloc] init];
    }
    return _messageManager;
}

- (TLChatTableViewController *)chatTableVC
{
    if (_chatTableVC == nil) {
        _chatTableVC = [[TLChatTableViewController alloc] init];
        [_chatTableVC setDelegate:self];
    }
    return _chatTableVC;
}

- (TLChatBar *)chatBar
{
    if (_chatBar == nil) {
        _chatBar = [[TLChatBar alloc] init];
        [_chatBar setDelegate:self.chatKeyboardController];
        [_chatBar setDataDelegate:self];
    }
    return _chatBar;
}

- (TLEmojiKeyboard *)emojiKeyboard
{
    if (_emojiKeyboard == nil) {
        _emojiKeyboard = [TLEmojiKeyboard keyboard];
        [_emojiKeyboard setKeyboardDelegate:self.chatKeyboardController];
        [_emojiKeyboard setDelegate:self];
    }
    return _emojiKeyboard;
}

- (TLMoreKeyboard *)moreKeyboard
{
    if (_moreKeyboard == nil) {
        _moreKeyboard = [TLMoreKeyboard keyboard];
        [_moreKeyboard setKeyboardDelegate:self.chatKeyboardController];
        [_moreKeyboard setDelegate:self];
    }
    return _moreKeyboard;
}

- (TLChatKeyboardController *)chatKeyboardController
{
    if (_chatKeyboardController == nil) {
        _chatKeyboardController = [[TLChatKeyboardController alloc] init];
    }
    return _chatKeyboardController;
}

@end
