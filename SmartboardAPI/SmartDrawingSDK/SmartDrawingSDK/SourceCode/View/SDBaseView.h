//
//  SDBaseView.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDBaseView;

@protocol SDBaseViewDelegate
@optional
- (void)elementSelected:(SDBaseView *)element;
- (void)elementDeselected:(SDBaseView *)element;
@end

@interface SDBaseView : UIView <UIGestureRecognizerDelegate>

- (UIView *)contentView;
- (void)moveTo:(CGPoint)dest;
- (void)rotateTo:(float)rotation;
- (void)scaleTo:(float)scale;
- (void)select;
- (void)deselect;

- (void)elementTap:(UITapGestureRecognizer *)tapGesture;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL allowToMove;
@property (nonatomic) BOOL allowToEdit;
@property (nonatomic) BOOL allowToSelect;
@property (nonatomic, assign) id<SDBaseViewDelegate> delegate;

@end
