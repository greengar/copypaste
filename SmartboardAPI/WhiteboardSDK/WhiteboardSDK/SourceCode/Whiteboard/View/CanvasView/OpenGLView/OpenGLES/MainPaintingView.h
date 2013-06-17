//
//  MainPaintingView.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 5/8/10.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingView.h"
#import "PaintingCmd.h"
#import "GSMutableDictionary.h"

#define kOffsetForZoomLabelWhenIPadPickerIsShown 130
#define kOffsetForZoomLabelWhenIPadPickerIsHidden 0

typedef enum {
    PaintingEventNone,
    
    PaintingEventDrawStart,
    PaintingEventDrawStroke,
    PaintingEventDrawAPoint,
    
    PaintingEventGestureStart,
    PaintingEventPan,
    PaintingEventZoom,
    PaintingEventShowPicker,
} PaintingEvent;

static const CGFloat kZoomMaxScale = 5;
static const CGFloat kZoomMinScale = 0.8;

@protocol MainPaintViewDelegate
@optional
- (void)startLineAtPoint:(CGPoint)start;
- (void)drawLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void)endLineAtPoint:(CGPoint)end;
- (void)addedCommandToUndoPool;
- (void)doneUndo:(int)undoCount;
- (void)doneRedo:(int)redoCount;
- (void)checkUndo:(int)undoCount;
- (void)checkRedo:(int)redoCount;
- (void)updateBoundingRect:(CGRect)boundingRect;
@end

@interface MainPaintingView : PaintingView <UIGestureRecognizerDelegate> {
	MainPaintingView *extDrawingView;
    int extRotation;
    
	GSMutableDictionary *touchDictionary;
	CGFloat gestureStartX;
	CGFloat gestureStartY;
	BOOL isPegged;
    
	NSMutableArray      * undoSequenceArray;
	NSMutableArray      * redoSequenceArray;
	PaintingCmd         * currentCmd;
    
	BOOL isReceivingStroke;
	BOOL isDrawingStroke;
	
	CGImageRef screenImgBeforeTexting;
    
    // last event is used to avoid unexpected gesture, accidental drawing, such as:
    // 1. When hiding picker is enable, touchEnd with 2 fingers for panning, can mislead to 2-finger-tap for show picker
    // 2. After zooming, 2 finger is less likely leave screen at the same time,
    // this causes an event to draw a point
    PaintingEvent lastPaintingEvent;
    int           numOfFingerOn;
    BOOL          gotMovement;
    BOOL          firstDrawingPoint;    
    CGPoint       firstTouchPoint;
    UITouch      *firstUITouch;
    
    NSTimer *lastEventInterval;
    
    UILabel *_zoomLabel;
    int     _zoomOffsetFromTop;
    
    Transforms _actualTransform;
    Transforms _transforms;    
}

@property (nonatomic, retain) PaintingView          * extDrawingView;
@property (nonatomic) Transforms                      _actualTransform;
@property (nonatomic) Transforms                      transforms;
@property (nonatomic) BOOL                            isDrawingStroke;
@property (nonatomic) int                             extRotation;
@property (nonatomic) int                             _zoomOffsetFromTop;
@property (nonatomic, assign) id<MainPaintViewDelegate> delegate;
@property (nonatomic) CGPoint                         topLeftBounding;
@property (nonatomic) CGPoint                         bottomRightBounding;

- (id)initWithDict:(NSDictionary *)dict;
- (id)initWithFrame:(CGRect)frame sharegroupView:(EAGLView *)glView;
- (void)initialDrawing;
- (void)reset;

- (BOOL)transferToPaintingView:(PaintingView *)ext;
- (void)loadAutosavedImg:(CGImageRef)image;
- (BOOL)saveAndOpenImage;

- (BOOL)undoStroke;
- (BOOL)checkUndo;
- (void)pushCommandToUndoStack:(PaintingCmd *)cmd;

- (BOOL)redoStroke;
- (BOOL)checkRedo;
- (void)pushCommandToRedoStack:(PaintingCmd *)cmd;

- (void)touchesMovedZoomAtCenter:(CGPoint)center
                     newDistance:(CGFloat)dist
                     oldDistance:(CGFloat)dist_last;
- (CGPoint)centerZoomFromTouch1:(CGPoint)fromTouch1
                     fromTouch2:(CGPoint)fromTouch2
                       toTouch1:(CGPoint)toTouch1
                       toTouch2:(CGPoint)toTouch2;
- (void)touchesMovedPan:(CGSize)displacedRect;
- (void)setZoomWithScale:(CGFloat)scale;
- (void)showZoomingLabel;
- (int)roundUpPercent:(CGFloat)number;

- (BOOL)shouldCreateElement;

- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void)addPointToUndoRedoSpaceFromPoint:(CGPoint)start toPoint:(CGPoint)end
                                colorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
                              strokeSize:(float)size
                              paintingId:(NSString *)paintId;

- (void)addCurrentImageToUndoRedoSpace;
- (void)addClearUndoCommand:(int)layer;

- (void)drawViewNoExternal;

- (BOOL)removeLayer:(int)index;
- (void)clearLayer:(int)layerIndex;
- (void)moveLayerAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2;

- (NSDictionary *)saveToDict;
+ (MainPaintingView *)loadFromDict:(NSDictionary *)dict;

- (void)reloadView;
@end

