//
//  WBMenubarView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//
//  This is the menu bar at the top left of the screen.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"

@protocol WBMenubarDelegate
- (void)menuButtonTappedFrom:(UIView *)view;
- (void)performUndo;
- (void)historyButtonTappedFrom:(UIView *)view;
@end

@interface WBMenubarView : UIView

- (void)didShowMenuView:(BOOL)success;
- (void)didShowHistoryView:(BOOL)success;

@property (nonatomic, assign) id<WBMenubarDelegate> delegate;

@end
