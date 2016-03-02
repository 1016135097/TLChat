//
//  TLFriendDetailViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/26.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLFriendDetailViewController.h"
#import "TLFriendDetailUserCell.h"
#import "TLFriendDetailAlbumCell.h"
#import "TLFriendHelper.h"
#import "TLChatViewController.h"
#import "TLRootViewController.h"

#define     HEIGHT_USER_CELL           90.0f
#define     HEIGHT_ALBUM_CELL          80.0f

@implementation TLFriendDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"详细资料"];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDown:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    [self.tableView registerClass:[TLFriendDetailUserCell class] forCellReuseIdentifier:@"TLFriendDetailUserCell"];
    [self.tableView registerClass:[TLFriendDetailAlbumCell class] forCellReuseIdentifier:@"TLFriendDetailAlbumCell"];
}

- (void)setUser:(TLUser *)user
{
    _user = user;
    NSArray *array = [TLFriendHelper transformFriendDetailArrayFromUserInfo:self.user];
    self.data = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

#pragma mark - Delegate -
//MARK: UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLInfo *info = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == TLInfoTypeOther) {
        if (indexPath.section == 0) {
            TLFriendDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLFriendDetailUserCell"];
            [cell setInfo:info];
            [cell setTopLineStyle:TLCellLineStyleFill];
            [cell setBottomLineStyle:TLCellLineStyleFill];
            return cell;
        }
        else {
            TLFriendDetailAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLFriendDetailAlbumCell"];
            [cell setInfo:info];
            return cell;
        }
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
//MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLInfo *info = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == TLInfoTypeOther) {
        if (indexPath.section == 0) {
            return HEIGHT_USER_CELL;
        }
        return HEIGHT_ALBUM_CELL;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


//MARK: TLInfoButtonCellDelegate
- (void)infoButtonCellClicked:(TLInfo *)info
{
    if ([info.title isEqualToString:@"发消息"]) {
        TLChatViewController *chatVC = [TLChatViewController sharedChatVC];
        if ([self.navigationController findViewController:@"TLChatViewController"]) {
            if ([chatVC.user.userID isEqualToString:self.user.userID]) {
                [self.navigationController popToViewControllerWithClassName:@"TLChatViewController" animated:YES];
            }
            else {
                [chatVC setUser:self.user];
                __block id navController = self.navigationController;
                [self.navigationController popToRootViewControllerAnimated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [navController pushViewController:chatVC animated:YES];
                    }
                }];
            }
        }
        else {
            [chatVC setUser:self.user];
            UIViewController *vc = [[TLRootViewController sharedRootViewController] childViewControllerAtIndex:0];
            [[TLRootViewController sharedRootViewController] setSelectedIndex:0];
            [vc setHidesBottomBarWhenPushed:YES];
            [vc.navigationController pushViewController:chatVC animated:YES completion:^(BOOL finished) {
                [self.navigationController popViewControllerAnimated:NO];
            }];
            [vc setHidesBottomBarWhenPushed:NO];
        }
    }
    else {
        [super infoButtonCellClicked:info];
    }
}


#pragma mark - Event Response -
- (void)rightBarButtonDown:(UIBarButtonItem *)sender
{

}

@end
