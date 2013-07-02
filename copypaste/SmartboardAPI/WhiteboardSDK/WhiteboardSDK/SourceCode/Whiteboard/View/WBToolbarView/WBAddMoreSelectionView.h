//
//  WBAddMoreSelectionView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"

#define ADD_MORE_ARRAY @[@"Use Camera", @"Add Photo", @"Add Text", @"Paste"/*, @"Add Background"*/]

#define kAddMoreCellHeight 79
#define kAddMoreViewHeight kAddMoreCellHeight*[ADD_MORE_ARRAY count]

@protocol WBAddMoreSelectionDelegate
- (void)addCameraFrom:(UIView *)view;
- (void)addPhotoFrom:(UIView *)view;
- (void)addTextFrom:(UIView *)view;
- (void)addPasteFrom:(UIView *)view;
- (void)addBackgroundFrom:(UIView *)view;
@end

@interface WBAddMoreSelectionView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)animateUp;
- (void)animateDown;

@property (nonatomic, assign) id<WBAddMoreSelectionDelegate> delegate;

@end
