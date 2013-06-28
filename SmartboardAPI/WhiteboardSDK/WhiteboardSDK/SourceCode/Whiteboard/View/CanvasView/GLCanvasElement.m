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
#import "GSButton.h"

@interface GLCanvasElement() {
    MainPaintingView *drawingView;
    CGRect boundingRect;
    UIImageView *screenshotImageView;
    NSString *currentBrushId;
    BOOL isCrop;
}

@end

@implementation GLCanvasElement

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

- (void)updateBoundingRect:(CGRect)rect {
    boundingRect = rect;
}

- (BOOL)isCropped {
    return isCrop;
}

- (void)crop {
    if (![self isCropped]) {
        drawingView.frame = CGRectMake(-boundingRect.origin.x, -boundingRect.origin.y,
                                       drawingView.frame.size.width, drawingView.frame.size.height);
        screenshotImageView.frame = drawingView.frame;
        self.frame = boundingRect;
        self.defaultFrame = self.frame;
        isCrop = YES;
    }
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
}

#pragma mark - Fake/Real Canvas
- (void)fakeCanvasShouldBeReal:(UIView *)paintingView {
    self.isFake = NO;
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(fakeCanvasFromElementShouldBeReal:)]) {
        [self.delegate fakeCanvasFromElementShouldBeReal:self];
    }
}

#pragma mark - Undo/Redo
- (void)pushedCommandToUndoStack:(PaintingCmd *)cmd {
    currentBrushId = [[HistoryManager sharedManager] addActionBrushElement:self
                                                                        forPage:(WBPage *)self.superview
                                                            withPaintingCommand:cmd
                                                                      withBlock:^(HistoryAction *history, NSError *error) {
                                                                        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                            [self.delegate pageHistoryCreated:history];
                                                                        }
                                                                    }];
}

- (void)updatedCommandOnUndoStack:(PaintingCmd *)cmd {
    [[HistoryManager sharedManager] updateActionBrushElementWithId:currentBrushId
                                               withPaintingCommand:cmd
                                                           forPage:(WBPage *)self.superview
                                                withBlock:^(HistoryAction *history, NSError *error) {
                                                    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryElementCanvasUpdated:withNewPaintingCmd:)]) {
                                                        [self.delegate pageHistoryElementCanvasUpdated:history
                                                                                    withNewPaintingCmd:cmd];
                                                    }
                                                }];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    drawingView = nil;
}

@end
