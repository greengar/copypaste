//
//  CGPaintingView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/13/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CGPaintingView.h"
#import "PaintingManager.h"
#import "SettingManager.h"

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface CGPaintingView()
@property (nonatomic) BOOL shouldCreateNewElement;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic) CGPoint firstPoint, secondPoint, currentPoint;
@end

@implementation CGPaintingView
@synthesize shouldCreateNewElement = _shouldCreateElement;
@synthesize paths = _paths;
@synthesize path = _path;
@synthesize firstPoint = _firstPoint;
@synthesize secondPoint = _secondPoint;
@synthesize currentPoint = _currentPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.paths = [NSMutableArray new];
    }
    return self;
}

- (BOOL)shouldCreateElement {
    return self.shouldCreateNewElement;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.shouldCreateNewElement = YES;
    
    UITouch *touch = [touches anyObject];
    self.firstPoint = [touch previousLocationInView:self];
    self.secondPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineCapStyle:kCGLineCapRound];
    [path setLineWidth:10.0f];
    [path moveToPoint:self.currentPoint];
    [path addLineToPoint:self.currentPoint];
    
    [self.paths addObject:path];
    self.path = path;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // here we save 3 last points
    self.secondPoint = self.firstPoint;
    self.firstPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    //points in the middle of the line segments
    CGPoint mid1 = midPoint(self.firstPoint, self.secondPoint);
    CGPoint mid2 = midPoint(self.currentPoint, self.firstPoint);
    
    // Start new curve between two actual touches.
    [self.path moveToPoint:mid1];
    
    // Curves connect in middle points and use actual touch points as control points.
    [self.path addQuadCurveToPoint:mid2 controlPoint:self.firstPoint];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] setStroke];
    for (UIBezierPath *path in self.paths) {
        [path stroke];
    }
}

@end
