//
//  SDBaseView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDBaseView.h"
#import "SDUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface SDBaseView()
@end

@implementation SDBaseView
@synthesize uid = _uid;
@synthesize delegate = _delegate;
@synthesize allowToMove = _allowToMove;
@synthesize allowToEdit = _allowToEdit;
@synthesize allowToSelect = _allowToSelect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [SDUtils generateUniqueId];
        self.allowToMove = YES;
        self.allowToEdit = YES;
        self.allowToSelect = YES;
        
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"SmartDrawing.bundle/DottedImage.png"]] CGColor];
        
    }
    return self;
}

- (void)setAllowToMove:(BOOL)allowToMove {
    _allowToMove = allowToMove;
    if (_allowToMove) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(elementPan:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = self;
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(elementRotate:)];
        rotationGesture.delegate = self;
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(elementScale:)];
        pinchGesture.delegate = self;
        
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:rotationGesture];
        [self addGestureRecognizer:pinchGesture];
        
    } else {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if (![gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [self removeGestureRecognizer:gesture];
            }
        }
    }
}

- (void)setAllowToSelect:(BOOL)allowToSelect {
    _allowToSelect = allowToSelect;
    if (_allowToSelect) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(elementTap:)];
        tapGesture.delegate = self;
        
        [self addGestureRecognizer:tapGesture];
        
    } else {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [self removeGestureRecognizer:gesture];
            }
        }
    }
}

- (UIView *)contentView {
    return nil; // This is a very base class, which does not have a content view inside
}

- (void)moveTo:(CGPoint)dest {
    [self setTransform:CGAffineTransformTranslate(self.transform, dest.x, dest.y)];
}

- (void)rotateTo:(float)rotation {
    [self setTransform:CGAffineTransformRotate(self.transform, rotation)];
}

- (void)scaleTo:(float)scale {
    [self setTransform:CGAffineTransformScale(self.transform, scale, scale)];
}

- (void)select {
    if ([self contentView]) {
        [[self contentView] becomeFirstResponder];
        [[self superview] bringSubviewToFront:self];
        self.layer.borderWidth = 1;
    };
}

- (void)deselect {
    if ([self contentView]) {
        [[self contentView] resignFirstResponder];
        self.layer.borderWidth = 0;
    };
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementDeselected:)]) {
        [self.delegate elementDeselected:self];
    }
}

- (void)elementTap:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.delegate elementSelected:self];
    }
}

- (void)elementPan:(UIPanGestureRecognizer *)panGesture {
    if ([panGesture state] == UIGestureRecognizerStateBegan || [panGesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self];
        [self moveTo:translation];
        [panGesture setTranslation:CGPointZero inView:self];
    }
}

- (void)elementRotate:(UIRotationGestureRecognizer *)rotationGesture {
    if ([rotationGesture state] == UIGestureRecognizerStateBegan || [rotationGesture state] == UIGestureRecognizerStateChanged) {
        float rotation = [rotationGesture rotation];
        [self rotateTo:rotation];
        [rotationGesture setRotation:0];
    }
}

- (void)elementScale:(UIPinchGestureRecognizer *)pinchGesture {
    if ([pinchGesture state] == UIGestureRecognizerStateBegan || [pinchGesture state] == UIGestureRecognizerStateChanged) {
        float scale = pinchGesture.scale;
        [self scaleTo:scale];
        [pinchGesture setScale:1.0f];
    }
}

@end
