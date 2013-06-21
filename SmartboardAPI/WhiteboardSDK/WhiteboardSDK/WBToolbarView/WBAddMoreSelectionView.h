//
//  WBAddMoreSelectionView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"

#define kAddMoreCellHeight 79
#define kAddMoreViewHeight kAddMoreCellHeight*4

@protocol WBAddMoreSelectionDelegate
- (void)addCameraFrom:(UIView *)view;
- (void)addPhotoFrom:(UIView *)view;
- (void)addTextFrom:(UIView *)view;
- (void)addCanvasFrom:(UIView *)view;
- (void)addPasteFrom:(UIView *)view;
@end

@interface WBAddMoreSelectionView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)animateUp;
- (void)animateDown;

@property (nonatomic, assign) id<WBAddMoreSelectionDelegate> delegate;
@property (nonatomic) BOOL isCanvasMode;

@end
