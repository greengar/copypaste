//
//  WBMenubarView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBMenubarDelegate
- (void)showMenu;
- (void)performUndo;
- (void)historyButtonTappedFrom:(UIView *)view;
@end

@interface WBMenubarView : UIView

- (void)didShowHistoryView:(BOOL)success;

@property (nonatomic, assign) id<WBMenubarDelegate> delegate;

@end
