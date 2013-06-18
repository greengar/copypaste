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

#define kHistoryCellHeight 79
#define kHistoryTitleHeight 44
#define kHistoryViewHeight (kHistoryTitleHeight+4*kHistoryCellHeight)

@protocol HistoryViewDelegate
- (void)historyClosed;
@end

@interface HistoryView : UIView <UITableViewDelegate, UITableViewDataSource, HistoryManagerDelegate>
- (void)animateUp;
- (void)animateDown;

@property (nonatomic, assign) id<HistoryViewDelegate> delegate;

@end
