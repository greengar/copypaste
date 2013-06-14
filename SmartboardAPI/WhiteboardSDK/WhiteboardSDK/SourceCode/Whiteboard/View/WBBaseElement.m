//
//  SDBaseElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBaseElement.h"
#import "TextElement.h"
#import "GLCanvasElement.h"
#import "ImageElement.h"
#import "BackgroundElement.h"
#import "WBUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoryManager.h"
#import "HistoryElementTransform.h"
#import "KxMenu.h"

@interface WBBaseElement()
@end

@implementation WBBaseElement
@synthesize uid = _uid;
@synthesize delegate = _delegate;
@synthesize isLocked = _isLocked;
@synthesize defaultFrame = _defaultFrame;
@synthesize defaultTransform = _defaultTransform;
@synthesize currentTransform = _currentTransform;
@synthesize elementCreated = _elementCreated;

- (id)initWithDict:(NSDictionary *)dictionary {
    CGRect frame = CGRectFromString([dictionary objectForKey:@"element_default_frame"]);
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [dictionary objectForKey:@"element_uid"];
        self.defaultTransform = CGAffineTransformFromString([dictionary objectForKey:@"element_default_transform"]);
        self.currentTransform = CGAffineTransformFromString([dictionary objectForKey:@"element_current_transform"]);
        self.defaultFrame = frame;        
        self.transform = self.currentTransform;

        self.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"E_"];
        self.defaultTransform = self.transform;
        self.currentTransform = self.transform;
        self.defaultFrame = frame;
        
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        
    }
    return self;
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
    if (isLocked) {
        UIPanGestureRecognizer *panGesture;
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(elementPan:)];
        panGesture.maximumNumberOfTouches = 2;
        panGesture.delegate = self;
        
        UIRotationGestureRecognizer *rotateGesture;
        rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(elementRotate:)];
        rotateGesture.delegate = self;
        
        UIPinchGestureRecognizer *pinchGesture;
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(elementScale:)];
        pinchGesture.delegate = self;
        
        UILongPressGestureRecognizer *pressGesture;
        pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(elementPress:)];
        pressGesture.delegate = self;
        
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:rotateGesture];
        [self addGestureRecognizer:pinchGesture];
        [self addGestureRecognizer:pressGesture];
        
        [[self contentView] setUserInteractionEnabled:NO];
        [self setAlpha:0.7f];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setBorderWidth:4];
        
    } else {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            [self removeGestureRecognizer:gesture];
        }
        
        [[self contentView] setUserInteractionEnabled:YES];
        [self setAlpha:1.0f];
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:0];
    }
}

- (UIView *)contentView {
    return nil; // This is a very base class, which does not have a content view inside
}

#pragma mark - Transform
- (void)moveTo:(CGPoint)dest {
    [self setTransform:CGAffineTransformTranslate(self.transform, dest.x, dest.y)];
}

- (void)rotateTo:(float)rotation {
    [self setTransform:CGAffineTransformRotate(self.transform, rotation)];
}

- (void)scaleTo:(float)scale {
    [self setTransform:CGAffineTransformScale(self.transform, scale, scale)];
}

- (void)resetTransform {
    [self setTransform:self.defaultTransform];
}

- (void)setTransform:(CGAffineTransform)transform {
    if (!CGAffineTransformEqualToTransform(transform, self.defaultTransform)) {
        self.currentTransform = transform;
    }
    [super setTransform:transform];
}

#pragma mark - Actions on Content View
- (void)select {
    if ([self contentView]) {
        [[self contentView] setUserInteractionEnabled:YES];
        [[self contentView] becomeFirstResponder];
    };
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.delegate elementSelected:self];
    }
}

- (void)deselect {
    if ([self contentView]) {
        [[self contentView] setUserInteractionEnabled:NO];
        [[self contentView] resignFirstResponder];
    };
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementDeselected:)]) {
        [self.delegate elementDeselected:self];
    }
}

- (BOOL)isTransformed {
    return !CGAffineTransformEqualToTransform(self.currentTransform, self.defaultTransform);
}

- (void)showMenu {
    NSArray *menuItems = @[[KxMenuItem menuItem:@"Edit"
                                          image:nil
                                         target:self
                                         action:@selector(select)],
                           [KxMenuItem menuItem:@"Send to back"
                                          image:nil
                                         target:self
                                         action:@selector(sendBack)],
                           [KxMenuItem menuItem:@"Bring to front"
                                          image:nil
                                         target:self
                                         action:@selector(bringFront)],
                           [KxMenuItem menuItem:@"Delete"
                                          image:nil
                                         target:self
                                         action:@selector(delete)], ];
    UIView *focusView = [[UIView alloc] initWithFrame:[self focusFrame]];
    focusView.transform = self.transform;
    [KxMenu showMenuInView:[self superview]
                  fromRect:focusView.frame
                 menuItems:menuItems];
}

- (void)bringFront {
    [[self superview] bringSubviewToFront:self];
}

- (void)sendBack {
    [[self superview] sendSubviewToBack:self];
}

- (void)delete {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementDeleted:)]) {
        [self.delegate elementDeleted:self];
    }
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)elementPan:(UIPanGestureRecognizer *)panGesture {
    if ([panGesture state] == UIGestureRecognizerStateBegan || [panGesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self];
        [self moveTo:translation];
        [panGesture setTranslation:CGPointZero inView:self];
    }
    
    // Add to History
    if ([panGesture state] == UIGestureRecognizerStateBegan) {
        HistoryElementTransform *action = [[HistoryElementTransform alloc] initWithName:@"Moved"];
        [[HistoryManager sharedManager] addAction:action];
        [action setElement:self];
        [action setOriginalTransform:self.transform];
        
    } else if ([panGesture state] == UIGestureRecognizerStateEnded) {
        [((HistoryElementTransform *) [[HistoryManager sharedManager] currentAction]) setChangedTransform:self.transform];
        [[HistoryManager sharedManager] finishAction];
    }
}

- (void)elementRotate:(UIRotationGestureRecognizer *)rotationGesture {
    if ([rotationGesture state] == UIGestureRecognizerStateBegan || [rotationGesture state] == UIGestureRecognizerStateChanged) {
        float rotation = [rotationGesture rotation];
        [self rotateTo:rotation];
        [rotationGesture setRotation:0];
    }
    
    // Add to History
    if ([rotationGesture state] == UIGestureRecognizerStateBegan) {
        HistoryElementTransform *action = [[HistoryElementTransform alloc] initWithName:@"Rotated"];
        [[HistoryManager sharedManager] addAction:action];
        [action setElement:self];
        [action setOriginalTransform:self.transform];
        
    } else if ([rotationGesture state] == UIGestureRecognizerStateEnded) {
        [((HistoryElementTransform *) [[HistoryManager sharedManager] currentAction]) setChangedTransform:self.transform];
        [[HistoryManager sharedManager] finishAction];
    }
}

- (void)elementScale:(UIPinchGestureRecognizer *)pinchGesture {
    if ([pinchGesture state] == UIGestureRecognizerStateBegan || [pinchGesture state] == UIGestureRecognizerStateChanged) {
        float scale = pinchGesture.scale;
        [self scaleTo:scale];
        [pinchGesture setScale:1.0f];
    }
    
    // Add to History
    if ([pinchGesture state] == UIGestureRecognizerStateBegan) {
        HistoryElementTransform *action = [[HistoryElementTransform alloc] initWithName:@"Scaled"];
        [[HistoryManager sharedManager] addAction:action];
        [action setElement:self];
        [action setOriginalTransform:self.transform];
        
    } else if ([pinchGesture state] == UIGestureRecognizerStateEnded) {
        [((HistoryElementTransform *) [[HistoryManager sharedManager] currentAction]) setChangedTransform:self.transform];
        [[HistoryManager sharedManager] finishAction];
    }
}

- (void)elementPress:(UILongPressGestureRecognizer *)pressGesture {
    if ([pressGesture state] == UIGestureRecognizerStateBegan) {
        [self showMenu];
    }
}

- (CGRect)focusFrame {
    return [[self contentView] frame];
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"element_uid"];
    [dict setObject:NSStringFromCGAffineTransform(self.defaultTransform) forKey:@"element_default_transform"];
    [dict setObject:NSStringFromCGAffineTransform(self.currentTransform) forKey:@"element_current_transform"];
    [dict setObject:NSStringFromCGRect(self.defaultFrame) forKey:@"element_default_frame"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    WBBaseElement *element = nil;
    
    NSString *elementType = [dictionary objectForKey:@"element_type"];
    if ([elementType isEqualToString:@"TextElement"]) {
        element = [TextElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"CanvasElement"]) {
        element = [GLCanvasElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"ImageElement"]) {
        element = [ImageElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"BackgroundElement"]) {
        element = [BackgroundElement loadFromDict:dictionary];
    }
    
    return element;
}

@end
