//
//  TLMessageBaseCell.h
//  TLChat
//
//  Created by 李伯坤 on 16/3/1.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMessage.h"

@interface TLMessageBaseCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *avatarButton;

@property (nonatomic, strong) UILabel *usernameLabel;

@end
