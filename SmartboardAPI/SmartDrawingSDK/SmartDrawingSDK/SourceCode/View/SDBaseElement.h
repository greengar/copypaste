//
//  SDBaseElement.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SDBaseElement;

@protocol SDBaseViewDelegate
@optional
- (void)elementSelected:(SDBaseElement *)element;
- (void)elementDeselected:(SDBaseElement *)element;
@end

@interface SDBaseElement : UIView <UIGestureRecognizerDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;
- (UIView *)contentView;
- (void)moveTo:(CGPoint)dest;
- (void)rotateTo:(float)rotation;
- (void)scaleTo:(float)scale;
- (void)select;
- (void)deselect;
- (void)resetTransform;
- (void)elementTap:(UITapGestureRecognizer *)tapGesture;

- (NSDictionary *)saveToDict;
+ (SDBaseElement *)loadFromDict:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL allowToMove;
@property (nonatomic) BOOL allowToEdit;
@property (nonatomic) BOOL allowToSelect;
@property (nonatomic, assign) id<SDBaseViewDelegate> delegate;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) CGAffineTransform defaultTransform;
@property (nonatomic) CGAffineTransform currentTransform;

@end
