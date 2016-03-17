//
//  TLChatTableViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/9.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatTableViewController.h"
#import "TLChatTableViewController+Delegate.h"
#import <MJRefresh.h>

#define     PAGE_MESSAGE_COUNT      15

@interface TLChatTableViewController ()

@property (nonatomic, strong) MJRefreshNormalHeader *refresHeader;

/// 用户决定新消息是否显示时间
@property (nonatomic, strong) NSDate *curDate;

@end

@implementation TLChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor colorChatTableViewBG]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 20)]];
    self.refresHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self p_tryToRefreshMoreRecord:^(NSInteger count, BOOL hasMore) {
            [self.tableView.mj_header endRefreshing];
            if (!hasMore) {
                self.tableView.mj_header = nil;
            }
            if (count > 0) {
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }];
    }];
    self.refresHeader.lastUpdatedTimeLabel.hidden = YES;
    self.refresHeader.stateLabel.hidden = YES;
    [self.tableView setMj_header:self.refresHeader];
    
    [self registerCellClass];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchTableView)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"2、 %lf %lf %lf %lf", self.tableView.x, self.tableView.y, self.tableView.width, self.tableView.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.menuView isShow]) {
        [self.menuView dismiss];
    }
}

#pragma mark - Public Methods -
- (void)reloadData
{
    [self.data removeAllObjects];
    [self.tableView reloadData];
    [self.tableView setMj_header:self.refresHeader];
    self.curDate = [NSDate date];
    [self p_tryToRefreshMoreRecord:^(NSInteger count, BOOL hasMore) {
        if (!hasMore) {
            self.tableView.mj_header = nil;
        }
        if (count > 0) {
            [self.tableView reloadData];
            NSLog(@"1、%lf %lf %lf %lf", self.tableView.x, self.tableView.y, self.tableView.width, self.tableView.height);
            [self.tableView scrollToBottomWithAnimation:NO];
        }
    }];
}

- (void)addMessage:(TLMessage *)message
{
    [self.data addObject:message];
    [self.tableView reloadData];
}

- (void)scrollToBottomWithAnimation:(BOOL)animation
{
    [self.tableView scrollToBottomWithAnimation:animation];
}

#pragma mark - Event Response -
- (void)didTouchTableView
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatTableViewControllerDidTouched:)]) {
        [_delegate chatTableViewControllerDidTouched:self];
    }
}

#pragma mark - Private Methods -
/**
 *  获取聊天历史记录
 */
- (void)p_tryToRefreshMoreRecord:(void (^)(NSInteger count, BOOL hasMore))complete
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatRecordsFromDate:count:completed:)]) {
        [_delegate chatRecordsFromDate:self.curDate
                                 count:PAGE_MESSAGE_COUNT
                             completed:^(NSDate *date, NSArray *array, BOOL hasMore) {
            if (array.count > 0 && [date isEqualToDate:self.curDate]) {
                self.curDate = [array[0] date];
                [self.data insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
                complete(array.count, hasMore);
            }
            else {
                complete(0, hasMore);
            }
        }];
    }
}

#pragma mark - Getter -
- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

- (TLChatCellMenuView *)menuView
{
    if (_menuView == nil) {
        _menuView = [[TLChatCellMenuView alloc] init];
    }
    return _menuView;
}

@end
