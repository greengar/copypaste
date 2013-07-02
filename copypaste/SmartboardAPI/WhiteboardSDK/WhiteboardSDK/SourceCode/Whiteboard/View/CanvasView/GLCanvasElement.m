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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // OpenGL View
        drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         frame.size.width,
                                                                         frame.size.height)];
        [self addSubview:drawingView];
        [drawingView setDelegate:self];
        [drawingView initialDrawing];
        
        self.isAlive = YES;
        self.isMovable = NO;
    }
    return self;
}

- (UIView *)contentView {
    return drawingView;
}

- (UIView *)contentDrawingView {
    return drawingView;
}

- (void)move {
    // We don't allow move the GLCanvasElement
}

- (void)stay {
    // We don't allow to move, so it will always stay
}

- (void)showMenuAt:(CGPoint)location {
    // We don't show the menu for the base canvas element
}

- (void)restore {
    self.transform = self.defaultTransform;
    self.frame = self.defaultFrame;
    self.transform = self.currentTransform;
    [drawingView drawView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesCancelled:touches withEvent:event];
    }
}

- (void)resetDrawingViewTouches {
    [drawingView resetDrawingViewTouches];
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
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
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
                     isErasing:(BOOL)isErasing {
    [self.delegate didRenderLineFromPoint:start
                                  toPoint:end
                           toURBackBuffer:toURBackBuffer
                                isErasing:isErasing
                               elementUid:self.uid];
}

#pragma mark - Collaboration Forward
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
                  isErasing:(BOOL)isErasing {
    [drawingView renderLineFromPoint:start
                             toPoint:end
                      toURBackBuffer:toURBackBuffer
                           isErasing:isErasing];
     
}

@end
