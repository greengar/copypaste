//
//  SDBaseElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class WBPage;
@class WBBaseElement;

@protocol WBBaseViewDelegate
@optional
- (void)elementCreated:(WBBaseElement *)element successful:(BOOL)successful;
- (void)elementSelected:(WBBaseElement *)element;
- (void)elementDeselected:(WBBaseElement *)element;
- (void)elementDeleted:(WBBaseElement *)element;
@end

@interface WBBaseElement : UIView <UIGestureRecognizerDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;
- (UIView *)contentView;
- (void)moveTo:(CGPoint)dest;
- (void)rotateTo:(float)rotation;
- (void)scaleTo:(float)scale;
- (void)select;
- (void)deselect;
- (void)resetTransform;
- (void)elementTap:(UITapGestureRecognizer *)tapGesture;
- (void)showMenu;
- (CGRect)focusFrame;
- (NSDictionary *)saveToDict;
+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL allowToMove;
@property (nonatomic) BOOL allowToEdit;
@property (nonatomic) BOOL allowToSelect;
@property (nonatomic, assign) id<WBBaseViewDelegate> delegate;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) CGAffineTransform defaultTransform;
@property (nonatomic) CGAffineTransform currentTransform;

@end
