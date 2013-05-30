//
//  SDBaseView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDBaseView.h"
#import <QuartzCore/QuartzCore.h>

@interface SDBaseView()
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@end

@implementation SDBaseView
@synthesize uid = _uid;
@synthesize delegate = _delegate;
@synthesize panGesture = _panGesture;
@synthesize rotationGesture = _rotationGesture;
@synthesize pinchGesture = _pinchGesture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(elementPan:)];
        self.panGesture.maximumNumberOfTouches = 1;
        self.panGesture.delegate = self;
        
        self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(elementRotate:)];
        self.rotationGesture.delegate = self;
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(elementScale:)];
        self.pinchGesture.delegate = self;
        
        [self addGestureRecognizer:self.panGesture];
        [self addGestureRecognizer:self.rotationGesture];
        [self addGestureRecognizer:self.pinchGesture];
    }
    return self;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.delegate elementSelected:self];
    }
}

@end
