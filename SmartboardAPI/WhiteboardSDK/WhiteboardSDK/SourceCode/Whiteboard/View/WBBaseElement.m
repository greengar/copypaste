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

@interface WBBaseElement() {
    BOOL isAlive;
    BOOL isMovable;
}
@property (nonatomic, strong) NSString *currentPanId;
@property (nonatomic, strong) NSString *currentRotateId;
@property (nonatomic, strong) NSString *currentScaleId;
@end

@implementation WBBaseElement
@synthesize uid = _uid;
@synthesize delegate = _delegate;
@synthesize defaultFrame = _defaultFrame;
@synthesize defaultTransform = _defaultTransform;
@synthesize currentTransform = _currentTransform;
@synthesize elementCreated = _elementCreated;
@synthesize border = _border;
@synthesize currentPanId = _currentPanId;
@synthesize currentRotateId = _currentRotateId;
@synthesize currentScaleId = _currentScaleId;
@synthesize isFake = _isFake;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"E_"];
        self.defaultTransform = self.transform;
        self.currentTransform = self.transform;
        self.defaultFrame = frame;
        self.clipsToBounds = YES;
        
        self.border = [CAShapeLayer layer];
        self.border.strokeColor = [UIColor orangeColor].CGColor;
        self.border.fillColor = nil;
        self.border.lineDashPattern = @[@4, @2];
        [self.layer addSublayer:self.border];
        [self.border setHidden:YES];
        
        self.isFake = NO;
    }
    return self;
}

- (void)layoutSubviews {
    self.border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.border.frame = self.bounds;
}

- (void)revive {
    [[self contentView] setUserInteractionEnabled:YES];
    isAlive = YES;
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementRevive:)]) {
        [self.delegate elementRevive:self];
    }
}

- (void)rest {
    [[self contentView] setUserInteractionEnabled:NO];
    isAlive = NO;
}

- (BOOL)isAlive {
    return isAlive;
}

- (void)move {
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(elementTap:)];
    tapGesture.delegate = self;
    
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
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
    [self addGestureRecognizer:rotateGesture];
    [self addGestureRecognizer:pinchGesture];
    [self addGestureRecognizer:pressGesture];
    
    [[self contentView] setUserInteractionEnabled:NO];
    [self.border setHidden:NO];
}

- (void)stay {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
    
    [[self contentView] setUserInteractionEnabled:YES];
    [self.border setHidden:YES];
}

- (BOOL)isMovable {
    return isMovable;
}

- (void)crop {
    
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
- (void)restore {
    
}

- (BOOL)isTransformed {
    return !CGAffineTransformEqualToTransform(self.currentTransform, self.defaultTransform);
}

- (BOOL)isCropped {
    return NO;
}

- (void)showMenuAt:(CGPoint)location {
    NSArray *menuItems = @[[KxMenuItem menuItem:@"Send to back"
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
    [KxMenu showMenuInView:self.superview.superview
                  fromRect:self.bounds
                 menuItems:menuItems];
}

- (void)bringFront {
    [[self superview] bringSubviewToFront:self];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(element:nowBringToFront:)]) {
        [self.delegate element:self nowBringToFront:YES];
    }
}

- (void)sendBack {
    [[self superview] sendSubviewToBack:self];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(element:nowSendToBack:)]) {
        [self.delegate element:self nowSendToBack:YES];
    }
}

- (void)delete {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(element:nowDeleted:)]) {
        [self.delegate element:self nowDeleted:YES];
    }
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)elementTap:(UITapGestureRecognizer *)tapGesture {
    if ([self isKindOfClass:[TextElement class]] && [tapGesture state] == UIGestureRecognizerStateEnded) {
        [self stay];
        [self revive];
    }
}

- (void)elementPan:(UIPanGestureRecognizer *)panGesture {
    // Add to History
    if ([panGesture state] == UIGestureRecognizerStateBegan) {
        self.currentPanId = [[HistoryManager sharedManager] addActionTransformElement:self
                                                                             withName:@"Move"
                                                                  withOriginTransform:self.transform
                                                                              forPage:(WBPage *)self.superview
                                                                            withBlock:^(NSArray *objects, NSError *error) {
                                                                                for (HistoryAction *action in objects) {
                                                                                    if (self.delegate &&
                                                                                        [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                                        [self.delegate pageHistoryCreated:action];
                                                                                    }
                                                                                }
                                                                            }];
    }
    
    if ([panGesture state] == UIGestureRecognizerStateEnded) {
        [[HistoryManager sharedManager] updateTransformElementWithId:self.currentPanId
                                                withChangedTransform:self.transform
                                                             forPage:(WBPage *)self.superview
                                                           withBlock:^(NSArray *objects, NSError *error) {
                                                               for (HistoryAction *action in objects) {
                                                                   if (self.delegate &&
                                                                       [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                       [self.delegate pageHistoryCreated:action];
                                                                   }
                                                               }
                                                           }];
    }
    
    if ([panGesture state] == UIGestureRecognizerStateBegan
        || [panGesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self];
        [self moveTo:translation];
        [panGesture setTranslation:CGPointZero inView:self];
    }
}

- (void)elementRotate:(UIRotationGestureRecognizer *)rotationGesture {
    // Add to History
    if ([rotationGesture state] == UIGestureRecognizerStateBegan) {
        self.currentRotateId = [[HistoryManager sharedManager] addActionTransformElement:self
                                                                                withName:@"Rotate"
                                                                     withOriginTransform:self.transform
                                                                                 forPage:(WBPage *)self.superview
                                                                               withBlock:^(NSArray *objects, NSError *error) {
                                                                                   for (HistoryAction *action in objects) {
                                                                                       if (self.delegate &&
                                                                                           [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                                           [self.delegate pageHistoryCreated:action];
                                                                                       }
                                                                                   }
                                                                               }];
    }
    
    if ([rotationGesture state] == UIGestureRecognizerStateEnded) {
        [[HistoryManager sharedManager] updateTransformElementWithId:self.currentRotateId
                                                withChangedTransform:self.transform
                                                             forPage:(WBPage *)self.superview
                                                           withBlock:^(NSArray *objects, NSError *error) {
                                                               for (HistoryAction *action in objects) {
                                                                   if (self.delegate &&
                                                                       [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                       [self.delegate pageHistoryCreated:action];
                                                                   }
                                                               }
                                                           }];
    }
    
    if ([rotationGesture state] == UIGestureRecognizerStateBegan
        || [rotationGesture state] == UIGestureRecognizerStateChanged) {
        float rotation = [rotationGesture rotation];
        [self rotateTo:rotation];
        [rotationGesture setRotation:0];
    }
}

- (void)elementScale:(UIPinchGestureRecognizer *)pinchGesture {
    // Add to History
    if ([pinchGesture state] == UIGestureRecognizerStateBegan) {
        self.currentScaleId = [[HistoryManager sharedManager] addActionTransformElement:self
                                                                               withName:@"Zoom"
                                                                    withOriginTransform:self.transform
                                                                                forPage:(WBPage *)self.superview
                                                                              withBlock:^(NSArray *objects, NSError *error) {
                                                                                  for (HistoryAction *action in objects) {
                                                                                      if (self.delegate &&
                                                                                          [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                                          [self.delegate pageHistoryCreated:action];
                                                                                      }
                                                                                  }
                                                                              }];
    }
    
    if ([pinchGesture state] == UIGestureRecognizerStateEnded) {
        [[HistoryManager sharedManager] updateTransformElementWithId:self.currentScaleId
                                                withChangedTransform:self.transform
                                                             forPage:(WBPage *)self.superview
                                                           withBlock:^(NSArray *objects, NSError *error) {
                                                               for (HistoryAction *action in objects) {
                                                                   if (self.delegate &&
                                                                       [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                       [self.delegate pageHistoryCreated:action];
                                                                   }
                                                               }
                                                           }];
    }
    
    if ([pinchGesture state] == UIGestureRecognizerStateBegan
        || [pinchGesture state] == UIGestureRecognizerStateChanged) {
        float scale = pinchGesture.scale;
        [self scaleTo:scale];
        [pinchGesture setScale:1.0f];
    }
}

- (void)elementPress:(UILongPressGestureRecognizer *)pressGesture {
    if ([pressGesture state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [pressGesture locationInView:self];
        [self showMenuAt:location];
    }
}

- (CGRect)focusFrame {
    return [[self contentView] frame];
}

#pragma mark - Machine State
- (void)create {
    
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"element_uid"];
    [dict setObject:NSStringFromCGAffineTransform(self.defaultTransform) forKey:@"element_default_transform"];
    [dict setObject:NSStringFromCGAffineTransform(self.currentTransform) forKey:@"element_current_transform"];
    [dict setObject:NSStringFromCGRect(self.defaultFrame) forKey:@"element_default_frame"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    self.uid = [elementData objectForKey:@"element_uid"];
    self.defaultFrame = CGRectFromString([elementData objectForKey:@"element_default_frame"]);
    self.frame = self.defaultFrame;
    self.defaultTransform = CGAffineTransformFromString([elementData objectForKey:@"element_default_transform"]);
    self.currentTransform =CGAffineTransformFromString([elementData objectForKey:@"element_current_transform"]);
    self.transform = self.currentTransform;
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
