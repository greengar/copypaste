//
//  SDBaseElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBaseElement.h"
#import "TextElement.h"
#import "CanvasElement.h"
#import "ImageElement.h"
#import "BackgroundElement.h"
#import "WBUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface WBBaseElement()
@end

@implementation WBBaseElement
@synthesize uid = _uid;
@synthesize delegate = _delegate;
@synthesize allowToMove = _allowToMove;
@synthesize allowToEdit = _allowToEdit;
@synthesize allowToSelect = _allowToSelect;
@synthesize defaultFrame = _defaultFrame;
@synthesize defaultTransform = _defaultTransform;
@synthesize currentTransform = _currentTransform;

- (id)initWithDict:(NSDictionary *)dictionary {
    CGRect frame = CGRectFromString([dictionary objectForKey:@"element_default_frame"]);
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [dictionary objectForKey:@"element_uid"];
        self.defaultTransform = CGAffineTransformFromString([dictionary objectForKey:@"element_default_transform"]);
        self.currentTransform = CGAffineTransformFromString([dictionary objectForKey:@"element_current_transform"]);
        self.defaultFrame = frame;
        self.allowToMove = YES;
        self.allowToEdit = YES;
        self.allowToSelect = YES;
        
        self.transform = self.currentTransform;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"Whiteboard.bundle/DottedImage.png"]] CGColor];
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
        self.allowToMove = YES;
        self.allowToEdit = YES;
        self.allowToSelect = YES;
        
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"Whiteboard.bundle/DottedImage.png"]] CGColor];
        
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

- (void)resetTransform {
    [self setTransform:self.defaultTransform];
}

- (void)setTransform:(CGAffineTransform)transform {
    if (!CGAffineTransformEqualToTransform(transform, self.defaultTransform)) {
        self.currentTransform = transform;
    }
    [super setTransform:transform];
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

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"element_uid"];
    [dict setObject:NSStringFromCGAffineTransform(self.defaultTransform) forKey:@"element_default_transform"];
    [dict setObject:NSStringFromCGAffineTransform(self.currentTransform) forKey:@"element_current_transform"];
    [dict setObject:NSStringFromCGRect(self.defaultFrame) forKey:@"element_default_frame"];
    return dict;
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    WBBaseElement *element = nil;
    
    NSString *elementType = [dictionary objectForKey:@"element_type"];
    if ([elementType isEqualToString:@"TextElement"]) {
        element = [TextElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"CanvasElement"]) {
        element = [CanvasElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"ImageElement"]) {
        element = [ImageElement loadFromDict:dictionary];
    } else if ([elementType isEqualToString:@"BackgroundElement"]) {
        element = [BackgroundElement loadFromDict:dictionary];
    }
    
    return element;
}

@end
