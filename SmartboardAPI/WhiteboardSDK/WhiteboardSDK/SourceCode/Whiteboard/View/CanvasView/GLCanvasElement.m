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
}
@property (nonatomic) UIView *previewAreaView;
@property (nonatomic, strong) UIImageView *screenshotImageView;
@property (nonatomic, strong) NSString *currentBrushId;
@end

@implementation GLCanvasElement
@synthesize previewAreaView = _previewAreaView;
@synthesize screenshotImageView = _screenshotImageView;
@synthesize currentBrushId = _currentBrushId;

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
        [self initControlWithFrame:frame];
        
        self.isFake = YES;
        
    }
    return self;
}

- (void)initControlWithFrame:(CGRect)frame {
//    self.previewAreaView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.drawingView setTopLeftBounding:CGPointZero];
//    [self.drawingView setBottomRightBounding:CGPointZero];
//    [self addSubview:self.previewAreaView];
//    
//    [self.previewAreaView setBackgroundColor:[UIColor clearColor]];
//    [self.previewAreaView setUserInteractionEnabled:NO];
//    [self.previewAreaView.layer setBorderWidth:1];
//    [self.previewAreaView.layer setBorderColor:[[UIColor blackColor] CGColor]];
}

- (UIView *)contentView {
    return drawingView;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *hitView = [super hitTest:point withEvent:event];
//    if (hitView == self && CGRectContainsPoint(self.previewAreaView.frame, point)) {
//        return hitView;
//    }
//    return nil;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    CGPoint location = [touch locationInView:self];
//    if (CGRectContainsPoint(self.previewAreaView.frame, location)) {
//        return YES;
//    }
//    return NO;
//}

//- (void)updateBoundingRect:(CGRect)boundingRect {
//    self.previewAreaView.frame = boundingRect;
//}

- (CGRect)focusFrame {
    return self.previewAreaView.frame;
}

#pragma marl - Screenshot
- (void)takeScreenshot {
    self.screenshotImageView = [[UIImageView alloc] initWithFrame:drawingView.frame];
    self.screenshotImageView.image = [drawingView glToUIImage];
    [self addSubview:self.screenshotImageView];
    [self sendSubviewToBack:self.screenshotImageView];
}

- (void)removeScreenshot {
    [self.screenshotImageView removeFromSuperview];
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"GLCanvasElement" forKey:@"element_type"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
    // Nothing to do honestly
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
    self.currentBrushId = [[HistoryManager sharedManager] addActionBrushElement:self
                                                                        forPage:(WBPage *)self.superview
                                                            withPaintingCommand:cmd
                                                                      withBlock:^(HistoryAction *history, NSError *error) {
                                                                        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                            [self.delegate pageHistoryCreated:history];
                                                                        }
                                                                    }];
}

- (void)updatedCommandOnUndoStack:(PaintingCmd *)cmd {
    [[HistoryManager sharedManager] updateActionBrushElementWithId:self.currentBrushId
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
