//
//  CPFriendListViewController.h
//  copypaste
//
//  Created by Hector Zhao on 5/1/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUser.h"
#import "EGOImageView.h"
#import "CPNavigationView.h"

@interface CPFriendListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGOImageViewDelegate, CPNavigationDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end
