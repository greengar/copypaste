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

@protocol CPFriendListViewDelegate
- (void)selectUser:(CPUser *)user;
@end

@interface CPFriendListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGOImageViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, weak) id<CPFriendListViewDelegate> delegate;

@end
