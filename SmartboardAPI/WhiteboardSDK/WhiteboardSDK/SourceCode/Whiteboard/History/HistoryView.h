//
//  HistoryView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryManager.h"
#import "SettingManager.h"
#import "WBPage.h"

#define kHistoryCellHeight 79
#define kHistoryTitleHeight 44
#define kHistoryViewHeight (kHistoryTitleHeight+4*kHistoryCellHeight)

@interface HistoryView : UIView <UITableViewDelegate, UITableViewDataSource, HistoryManagerDelegate>

- (void)animateUp;
- (void)animateDown;
- (void)reloadData;

@property (nonatomic, weak) WBPage *currentPage;

@end
