//
//  WBBottomRightToolbarView.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBAddMoreButton.h"
#import "WBMoveButton.h"

@protocol WBBottomRightToolbarDelegate
- (void)addMoreButtonTapped;
- (void)moveButtonTapped;
@end

@interface WBBottomRightToolbarView : UIView

@property (nonatomic, assign) id<WBBottomRightToolbarDelegate> delegate;

+ (CGSize)preferredSize;
- (void)didShowAddMoreView:(BOOL)success;
- (void)didActivatedMove:(BOOL)success;

@end
