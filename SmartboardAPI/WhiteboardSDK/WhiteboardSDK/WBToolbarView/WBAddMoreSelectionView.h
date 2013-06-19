//
//  WBAddMoreSelectionView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAddMoreCellHeight 79
#define kAddMoreViewHeight kAddMoreCellHeight*4

@protocol WBAddMoreSelectionDelegate
- (void)addCamera;
- (void)addPhoto;
- (void)addText;
- (void)addCanvas;
- (void)addPaste;
@end

@interface WBAddMoreSelectionView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)animateUp;
- (void)animateDown;

@property (nonatomic, assign) id<WBAddMoreSelectionDelegate> delegate;
@property (nonatomic) BOOL isCanvasMode;

@end
