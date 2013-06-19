//
//  WBBottomRightToolbarView.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBAddMoreButton.h"
#import "WBMoveButton.h"

@protocol WBBottomRightToolbarDelegate
- (void)showAddMore:(BOOL)show;
- (void)enableMove:(BOOL)enable;
@end

@interface WBBottomRightToolbarView : UIView

- (void)bottomRightClosed;

@property (nonatomic, assign) id<WBBottomRightToolbarDelegate> delegate;

@end
