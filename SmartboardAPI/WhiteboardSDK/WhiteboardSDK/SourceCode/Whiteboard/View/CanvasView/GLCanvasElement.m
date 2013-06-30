//
//  GLCanvasElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GLCanvasElement.h"
#import "SettingManager.h"
#import "HistoryManager.h"
#import "HistoryElementCanvasDraw.h"
#import "GSButton.h"
#import "WBPage.h"

@interface GLCanvasElement() {
    MainPaintingView *drawingView;
    UIImageView *screenshotImageView;
    NSString *currentBrushId;
}

@end

@implementation GLCanvasElement
@synthesize isCrop = _isCrop;
@synthesize boundingRect = _boundingRect;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // OpenGL View
        drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         frame.size.width,
                                                                         frame.size.height)];
        [self addSubview:drawingView];
        [drawingView setDelegate:self];
        [drawingView initialDrawing];
        
        self.isFake = YES;
        
    }
    return self;
}

- (UIView *)contentView {
    return drawingView;
}

- (BOOL)isCropped {
    return self.isCrop;
}

- (void)crop {
    self.transform = self.defaultTransform;
    drawingView.frame = CGRectMake(-self.boundingRect.origin.x, -self.boundingRect.origin.y,
                                   drawingView.frame.size.width, drawingView.frame.size.height);
    screenshotImageView.frame = drawingView.frame;
    self.frame = self.boundingRect;
    self.defaultFrame = self.frame;
    self.isCrop = YES;
    self.transform = self.currentTransform;
}

- (void)revive {
    if (![self isTransformed] && ![self isCropped]) {
        [super revive];
    } else {
        // Transformed or cropped, it will not be revivable
    }
}

- (void)rest {
    [super rest];
}

- (void)move {
    [super move];
}

- (void)stay {
    [super stay];
}

- (void)restore {
    self.transform = self.defaultTransform;
    self.frame = self.defaultFrame;
    self.transform = self.currentTransform;
    self.isFake = YES;
    [drawingView drawView];
}

#pragma marl - Screenshot
- (void)takeScreenshot {
    screenshotImageView = [[UIImageView alloc] initWithFrame:drawingView.frame];
    screenshotImageView.image = [drawingView glToUIImage];
    [self addSubview:screenshotImageView];
    [self sendSubviewToBack:screenshotImageView];
}

- (void)removeScreenshot {
    [screenshotImageView removeFromSuperview];
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"GLCanvasElement" forKey:@"element_type"];
    [dict setObject:[NSNumber numberWithBool:self.isFake] forKey:@"element_canvas_fake"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
    self.isFake = [[elementData objectForKey:@"element_canvas_fake"] boolValue];
    self.isCrop = YES;
}

#pragma mark - Fake/Real Canvas
- (void)didCreateRealCanvas {
    self.isFake = NO;
    self.isCrop = YES;
    [self.delegate didCreateRealCanvasWithUid:self.uid];
}

#pragma mark - Undo/Redo
- (void)pushedCommandToUndoStack:(PaintingCmd *)cmd {
    currentBrushId = [[HistoryManager sharedManager] addActionBrushElement:self
                                                                   forPage:(WBPage *)self.superview
                                                       withPaintingCommand:cmd
                                                                 withBlock:^(HistoryElementCanvasDraw *history, NSError *error) {}];
}

- (void)updatedCommandOnUndoStack:(PaintingCmd *)cmd {
    [[HistoryManager sharedManager] updateActionBrushElementWithId:currentBrushId
                                               withPaintingCommand:cmd
                                                           forPage:(WBPage *)self.superview
                                                         withBlock:^(HistoryElementCanvasDraw *history, NSError *error) {}];
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    drawingView = nil;
}

#pragma mark - Collaboration Back
- (void)didApplyColorRed:(float)red
                   green:(float)green
                    blue:(float)blue
                   alpha:(float)alpha
              strokeSize:(float)strokeSize {
    [self.delegate didApplyColorRed:red
                              green:green
                               blue:blue
                              alpha:alpha
                         strokeSize:strokeSize
                         elementUid:self.uid];
}

- (void)didRenderLineFromPoint:(CGPoint)start
                       toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer
                     isErasing:(BOOL)isErasing
                updateBoundary:(CGRect)boundingRect {
    self.boundingRect = boundingRect;
    [self.delegate didRenderLineFromPoint:start
                                  toPoint:end
                           toURBackBuffer:toURBackBuffer
                                isErasing:isErasing
                           updateBoundary:boundingRect
                               elementUid:self.uid];
}

#pragma mark - Collaboration Forward
- (void)createRealCanvas {
    self.isFake = NO;
    [drawingView createRealCanvas];
}

- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize {
    [drawingView applyColorRed:red
                         green:green
                          blue:blue
                         alpha:alpha
                    strokeSize:strokeSize];
}

- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing
             updateBoundary:(CGRect)boundingRect {
    self.boundingRect = boundingRect;
    [drawingView renderLineFromPoint:start
                             toPoint:end
                      toURBackBuffer:toURBackBuffer
                           isErasing:isErasing
                      updateBoundary:boundingRect];
     
}

@end
