//
//  MainPaintingView.m
// WhiteboardSDK
//
//  Created by Elliot Lee on 5/8/10.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MainPaintingView.h"
#import "MultiStrokePaintingCmd.h"
#import "StrokePaintingCmd.h"
#import "ImagePaintingCmd.h"
#import "ClearPaintingCmd.h"
#import "SettingManager.h"
#import "WBUtils.h"
#import "GSTouchData.h"

//#import "ImageManipulation.h" // for USE_PNG_FILE_FORMAT

#define kInvalidCoord (-100)
#define kUndoMaxBuffer 10

@interface MainPaintingView () {
    Transforms viewTransform;
}
@property (nonatomic, strong) NSString *currentPaintingId;
@property (nonatomic, strong) NSTimer *lastEventInterval;
- (void)showZoomingLabel;
- (BOOL)isNearStandardTransform;
- (BOOL)isZoomNearStandard;
- (BOOL)isPanNearStandard;
@end

@implementation MainPaintingView
@synthesize delegate = _delegate;
@synthesize extDrawingView;
@synthesize extRotation;
@synthesize lastEventInterval;
@synthesize _actualTransform;
@synthesize transforms;
@synthesize isDrawingStroke;
@synthesize _zoomOffsetFromTop;
@synthesize topLeftBounding;
@synthesize bottomRightBounding;

#pragma mark - Initialize
- (id)initWithDict:(NSDictionary *)dict {
    CGRect frame = CGRectFromString([dict objectForKey:@"opengl_frame"]);
    if (self = [super initWithFrame:frame]) {
        self.multipleTouchEnabled = YES;
        
        touchDictionary = [[GSMutableDictionary alloc] initWithCapacity:3];
		
		gestureStartX = kInvalidCoord;
		gestureStartY = kInvalidCoord;
		
		isReceivingStroke = NO;
		isDrawingStroke = NO;
		undoSequenceArray = [[NSMutableArray alloc] init];
		redoSequenceArray = [[NSMutableArray alloc] init];
        
        extRotation = 90;
        
        if (IS_IPAD) {
            _zoomOffsetFromTop = kOffsetForZoomLabelWhenIPadPickerIsShown;
        }
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame sharegroupView:(EAGLView *)glView {
    if ((self = [super initWithFrame:frame sharegroupView:glView])) {
        // You might think this is necessary for showing the tools, but it's not.
		self.multipleTouchEnabled = YES;

		touchDictionary = [[GSMutableDictionary alloc] initWithCapacity:3];
		
		gestureStartX = kInvalidCoord;
		gestureStartY = kInvalidCoord;
		
		isReceivingStroke = NO;
		isDrawingStroke = NO;
		undoSequenceArray = [[NSMutableArray alloc] init];
		redoSequenceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		// You might think this is necessary for showing the tools, but it's not.
		self.multipleTouchEnabled = YES;
		
		touchDictionary = [[GSMutableDictionary alloc] initWithCapacity:3];
		
		gestureStartX = kInvalidCoord;
		gestureStartY = kInvalidCoord;
		
		isReceivingStroke = NO;
		isDrawingStroke = NO;
		undoSequenceArray = [[NSMutableArray alloc] init];
		redoSequenceArray = [[NSMutableArray alloc] init];
        
        extRotation = 90;
        
        if (IS_IPAD) {
            _zoomOffsetFromTop = kOffsetForZoomLabelWhenIPadPickerIsShown;
        }
	}
	return self;
}

- (void)initialDrawing {
//    glColor4f(1.0, 1.0, 1.0, 1.0);
    [self setCurrentColorComponentWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    [self renderLineFromPoint:CGPointMake(-1, -1) toPoint:CGPointMake(-1, -1) toURBackBuffer:NO isErasing:NO];
    [self erase];
}

#pragma mark - Loading Images
- (BOOL)saveAndOpenImage {
	UIImage *image = [self glToUIImage];
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(drawUIImage:didFinishSavingWithError:contextInfo:), nil);
	return !!image;
}

- (BOOL)drawCGImage:(CGImageRef)image onPaintingView:(PaintingView *)ext release:(BOOL)release {
	if (!image) {
		return NO;
	}
	
	// load CGImageRef into ext in preparation for drawing
	if (![ext loadImage:image]) {
		return NO;
	}
	
	// NOTE: calling [self erase] actually erases MainPaintingView
	
	// draw loaded object on ext
	[ext drawObject];
	
	// reset marker color
	//[UIAppDelegate setMyColor];
	
	if (release) {
		// release image
		CGImageRelease(image);
	}
	
	return YES;
}

// copied from PaintingView.m
- (void)drawUIImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	// this is the only way it works
	
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[alert show];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"External Screen Connected"
                                                        message:@"Colors may not have transferred correctly, so your drawing has been Saved. Tap the 'Open' button to fix this issue by re-open your drawing."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[alert show];
	}
}

- (BOOL)loadFromSavedPhotoAlbum:(UIImage*)image {
    //	[extDrawingView setCurrentContext];
    //	[extDrawingView loadFromSavedPhotoAlbum:image];
	BOOL loadResult = [super loadFromSavedPhotoAlbum:image];
	
	//BOOL copyResult = 
	[self transferToPaintingView:self.extDrawingView];
	
	return loadResult;
}

- (void)loadAutosavedImg:(CGImageRef)image {
	if ([self loadImage:image]) {
		[self drawObject];
	}
    [self transferToPaintingView:self.extDrawingView];
}

- (BOOL)transferToPaintingView {
	return [self transferToPaintingView:extDrawingView];
}

- (BOOL)transferToPaintingView:(PaintingView *)extView {
	if (!extView) {
		return NO;
	}

	CGImageRef image = [self glToRotated90CGImageCreate];
    
	[extView loadImage:image];
	[extView drawObject];
    
    [[PaintingManager sharedManager] updateColor:nil of:nil];
    [[PaintingManager sharedManager] updatePointSize:0 of:nil];
    
	return YES;
}

#pragma mark - Render Lines on Canvas
- (void)addPointToLine:(NSString *)paintId fromPoint:(CGPoint)start toPoint:(CGPoint)end{
    CGFloat * components = [[PaintingManager sharedManager] getColorOf:nil];
    float strokeSize = [[PaintingManager sharedManager] getPointSizeOf:nil];
    [self addPointToUndoRedoSpaceFromPoint:start
                                   toPoint:end
                                  colorRed:components[0]
                                     green:components[1]
                                      blue:components[2]
                                     alpha:components[3]
                                strokeSize:strokeSize
                                paintingId:paintId];
}

- (void)addPointToUndoRedoSpaceFromPoint:(CGPoint)start toPoint:(CGPoint)end
                                colorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
                              strokeSize:(float)size
                              paintingId:(NSString *)paintId {
    
    StrokePaintingCmd *newCmd = [[StrokePaintingCmd alloc] init];
    [newCmd setDrawingView:self];
    [newCmd strokeFromPoint:start toPoint:end];
    [newCmd pointSizeWithSize:size];
    [newCmd colorWithRed:red green:green blue:blue alpha:alpha];
    [newCmd setLayerIndex:currentLayerIndex];
    
    if (paintId == nil) { // New line
        MultiStrokePaintingCmd *multiCmd = [[MultiStrokePaintingCmd alloc] init];
        [multiCmd.strokeArray addObject:newCmd];
        [self pushCommandToUndoStack:multiCmd];
        self.currentPaintingId = [NSString stringWithString:[multiCmd uid]];
        
    } else {
        BOOL paintingIdExisted = NO;
        if (paintId) {
            for (PaintingCmd *cmd in undoSequenceArray) {
                if ([[cmd uid] isEqualToString:paintId] && [cmd isKindOfClass:[MultiStrokePaintingCmd class]]) {
                    MultiStrokePaintingCmd *multiCmd = (MultiStrokePaintingCmd *)cmd;
                    [multiCmd.strokeArray addObject:newCmd];
                    paintingIdExisted = YES;
                    break;
                }
            }
        }
        
        if (!paintingIdExisted) { // No existing line with this Id, so create new one
            MultiStrokePaintingCmd *multiCmd = [[MultiStrokePaintingCmd alloc] init];
            [multiCmd.strokeArray addObject:newCmd];
            [self pushCommandToUndoStack:multiCmd];
            self.currentPaintingId = [NSString stringWithString:[multiCmd uid]];
        }
    }
}

- (void)applyLocalDrawingCmd {
    CGFloat *components = [[PaintingManager sharedManager] getColorOf:nil];
    GLfloat radius = [[PaintingManager sharedManager] getPointSizeOf:nil];
    [self applyColorRed:components[0]
                  green:components[1]
                   blue:components[2]
                  alpha:components[3]
             strokeSize:radius];
}

- (void)applyColorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
           strokeSize:(float)strokeSize {
    if (self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
    
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
	GLfloat radius = strokeSize * kTextureScale * 2;
    glPointSize(radius);
    glColor4f(red, green, blue, alpha);
    [self setCurrentColorComponentWithRed:red green:green blue:blue alpha:alpha];
    
    if (extDrawingView) {
        
    }
}

- (void)applyRemoteDrawingCmd {
    if (self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
    
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
    CGFloat * components = [[PaintingManager sharedManager] getColorOf:kCollaborator];
    
	GLfloat radius = [[PaintingManager sharedManager] getPointSizeOf:kCollaborator] * kTextureScale * 2;
    glPointSize(radius);
    glColor4f(components[0], components[1], components[2], components[3]);
    [self setCurrentColorComponentWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
    
    if (extDrawingView) {
        [extDrawingView applyRemoteDrawingCmd];
    }
}

- (void)addCurrentImageToUndoRedoSpace {
    ImagePaintingCmd * cmd = [[ImagePaintingCmd alloc] init];
    [cmd setLayerIndex:currentLayerIndex];
    [cmd setDrawingView:self];
    [cmd setCGIImage:[self glToCGImageCreate]];
    [self pushCommandToUndoStack:cmd];
    currentCmd = nil;
}

- (void)drawWhenTouchMove:(NSSet *)touches paintId:(NSString *)paintId {
	for (UITouch *touch in touches) {
        if (firstUITouch && touch != firstUITouch && [SettingManager sharedManager].isEnablePanZoom) {
            continue;
        }
        
		GSTouchData *touchData = [touchDictionary objectForKey:touch];
		touchData.firstTouch = NO;
		
		CGPoint location = [touch locationInView:self];
		CGPoint previousLocation = [touch previousLocationInView:self];
        
        [self drawLineFromTouchPoint:previousLocation toTouchPoint:location paintId:paintId];
        
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(drawLineFromPoint:toPoint:)]) {
            [self.delegate drawLineFromPoint:previousLocation toPoint:location];
        }
    }
}

- (void)drawWhenTouchEnd:(NSSet *)touches {
    for (UITouch *touch in touches) {
        if (firstUITouch && touch != firstUITouch && [SettingManager sharedManager].isEnablePanZoom) {
            continue;
        }
        
		GSTouchData *touchData = [touchDictionary objectForKey:touch];
        
		if (touchData.firstTouch) {
            DLog(@"Draw a point");
            
			touchData.firstTouch = NO;
            
			// a single point was touched
            CGPoint location = [touch locationInView:self];
            
            [self releaseRedoStack];
			[[SettingManager sharedManager] setupRenderPoint];
            [self applyLocalDrawingCmd];
            
            [self drawLineFromTouchPoint:location toTouchPoint:location paintId:nil];
			
            [[SettingManager sharedManager] teardownRenderPoint];
            [self applyLocalDrawingCmd];
            
		} else {
            CGPoint previousLocation = [touch previousLocationInView:self];
            CGPoint location = [touch locationInView:self];
            
            [self applyLocalDrawingCmd];
            [self drawLineFromTouchPoint:previousLocation toTouchPoint:location paintId:self.currentPaintingId];
        }
		
		if (touchData) { // defensive
			[touchDictionary removeObjectForKey:touch];
		}
        
	}
	
	isDrawingStroke = NO;

    CGPoint location = [[touches anyObject] locationInView:self];
    CGPoint end = CGPointMake(location.x, self.bounds.size.height - location.y);
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(endLineAtPoint:)]) {
        [self.delegate endLineAtPoint:end];
    }
}

- (void)drawLineFromTouchPoint:(CGPoint)previousLocation toTouchPoint:(CGPoint)location paintId:(NSString *)paintId {
    CGRect bounds = [self bounds];
    
    location = [self pointWithOutCameraEffect:location];
    previousLocation = [self pointWithOutCameraEffect:previousLocation];
    
    // peer expects point to be y-flipped
    CGPoint p1 = location;
    p1.y = bounds.size.height - p1.y;
    CGPoint p2 = previousLocation;
    p2.y = bounds.size.height - p2.y;
    
    // do our conversion after sending
    location = [self convertToGL:location];
    previousLocation = [self convertToGL:previousLocation];
    
    float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1;
    
    previousLocation.x = previousLocation.x / scale; previousLocation.y = previousLocation.y / scale;
    location.x = location.x / scale; location.y = location.y / scale;
    
    [self renderLineFromPoint:previousLocation toPoint:location];
    [self addPointToLine:paintId fromPoint:previousLocation toPoint:location];
}

// Mirror contents to BLVideoOut's drawingView (PaintingView instance)
// Cannot assume this line is supposed to be in my color (may be remote color)
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    not_run_when_in_background
    
    CGRect previewAreaRect = [self getBoundingOfDrawingUpdateFromPoint:start toPoint:end];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateBoundingRect:)]) {
        [self.delegate updateBoundingRect:previewAreaRect];
    }
    
    if(extDrawingView) {
        //NAM: Conversion to rotate 90
        Painting *me = [[PaintingManager sharedManager] getPainting:nil];
        Painting *ext = [[PaintingManager sharedManager] getPainting:kExternalScreen];
        //ext = me;
        CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
        CGFloat * pos = (CGFloat *)malloc(2 * sizeof(CGFloat));
        pos[0] = start.x;
        pos[1] = start.y;
        
        pos = [me translatePositionToCenter:pos];
        pos = [ext convertRotated90Position:pos from:me atCenter:YES];
        pos = [ext translatePositionToCenter:pos];
        pair = [ext rotatePosition:pos from:ext byDegree:90 atCenter:YES];
        //pair = [ext rotatePosition:pos from:ext byDegree:extRotation atCenter:YES];
        
        CGPoint _90_start = CGPointMake(pair[0], pair[1]);
        //    DLog(@"convert (%f, %f) to (%f, %f)", pos[0], pos[1], pair[0], pair[1]);
        
        pos[0] = end.x;
        pos[1] = end.y;
        
        pos = [me translatePositionToCenter:pos];
        pos = [ext convertRotated90Position:pos from:me atCenter:YES];
        pos = [ext translatePositionToCenter:pos];
        pair = [ext rotatePosition:pos from:ext byDegree:90 atCenter:YES];
        CGPoint	_90_end   = CGPointMake(pair[0], pair[1]);
        
        if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
            [extDrawingView renderLineFromPoint:_90_start toPoint:_90_end toURBackBuffer:NO isErasing:YES];
        } else {
            [extDrawingView renderLineFromPoint:_90_start toPoint:_90_end toURBackBuffer:NO isErasing:NO];
        }
    }
    
    if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
        [super renderLineFromPoint:start toPoint:end toURBackBuffer:NO isErasing:YES];
    } else {
        [super renderLineFromPoint:start toPoint:end toURBackBuffer:NO isErasing:NO];
    }
}

- (void)endPotenticalConflictEvent {
//    DLog();
//    lastPaintingEvent = PaintingEventNone;

}

- (void)setPaintingEvent:(PaintingEvent)event hasPotientialConfiction:(BOOL)willConflict {
    lastPaintingEvent = event;
    //Start a timer for 2 seconds.
    if ([lastEventInterval isValid]) {
        [lastEventInterval invalidate];
    }
    if (willConflict) {
        self.lastEventInterval = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
                                                                selector:@selector(endPotenticalConflictEvent) 
                                                                userInfo:nil repeats:NO];        
    }
}

#pragma mark - Touch Handlers
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (IS_IPAD) {
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        
        if (!layerInfo.offscreenLayerVisible ) {
            return;
        }        
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kHideRedoNotification object:nil];
    
    // Hector: Pan/Zoom is disable
    if (![SettingManager sharedManager].isEnablePanZoom) {
        for (UITouch *touch in touches) {
            GSTouchData *touchData = [[GSTouchData alloc] init];
            touchData.firstTouch = YES;
            [touchDictionary setObject:touchData forKey:touch];
        }
        
        [self releaseRedoStack];
        
        isDrawingStroke = TRUE;
        
        return;
    }

	switch ([touches count]) {
		case 1: { // Single touch
            numOfFingerOn++;
            if (numOfFingerOn > 2) {
                numOfFingerOn = 2;
            }

            if (!gotMovement) {
                
                if (numOfFingerOn == 1) {
                    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
                    firstTouchPoint = [touch1 locationInView:self];
                    firstTouchPoint = [self pointWithOutCameraEffect:firstTouchPoint];
                    firstUITouch = touch1;
                }
            }
           
		} break;
		case 2: { // Double Touch
            numOfFingerOn += 2;
            if (numOfFingerOn > 2) {
                numOfFingerOn = 2;
            }

            lastPaintingEvent = PaintingEventGestureStart;
            
		} break;
        case 3: {
            
        }
		default:
            break;
	}    
    
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (IS_IPAD) {
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        
        if (!layerInfo.offscreenLayerVisible) {
            return;
        }
    }
    
    // Hector: Pan/Zoom is disable
    if (![SettingManager sharedManager].isEnablePanZoom) {
        [self drawWhenTouchMove:touches paintId:self.currentPaintingId];
        return;
    }
	
    if (numOfFingerOn == 1 && lastPaintingEvent != PaintingEventPan && lastPaintingEvent != PaintingEventZoom) {
        if (!gotMovement) {
            
            UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
            CGPoint p1 = [touch1 locationInView:self];
            p1 = [self pointWithOutCameraEffect:p1];
            
            // prevent sensitive, shake finger
            // in this case user only tap, and hold still, doesn't want to draw a line
            if (fabs(p1.x - firstTouchPoint.x) < 5 && fabs(p1.y - firstTouchPoint.y) < 5) {
                //[self drawWhenTouchMove:touches];
                return;
            }
            gotMovement = YES;
        }
        
        // First Touch, draw the first point
        if (!firstDrawingPoint) {
            firstDrawingPoint = YES;
            [self releaseRedoStack];
            
            if ([touches count] == 1) {
                [self processTouch:[touches anyObject]];
            }
            
            for (UITouch *touch in touches) {
                GSTouchData *touchData = [[GSTouchData alloc] init];
                touchData.firstTouch = YES;
                [touchDictionary setObject:touchData forKey:touch];
            }
            
            isDrawingStroke = TRUE;
            
            CGPoint location = [[touches anyObject] locationInView:self];
            CGPoint start = CGPointMake(location.x, self.bounds.size.height - location.y);
            
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(startLineAtPoint:)]) {
                [self.delegate startLineAtPoint:start];
            }
            
            lastPaintingEvent = PaintingEventDrawStart;
            
            [self applyLocalDrawingCmd];
            
            // save firstTouchPoint of the first finger
            // will update firstTouchPoint on drawWhenTouchMove
            // in order to identify the first finger's movement
            UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
            CGPoint p1 = [touch1 locationInView:self];
            firstTouchPoint = p1;
            firstUITouch = touch1;
            
            // First touch, so start a new line (nil id)
            [self drawWhenTouchMove:touches paintId:nil];
            
        } else {            
            if (lastPaintingEvent == PaintingEventDrawStart) {
                [self releaseRedoStack];
                [self applyLocalDrawingCmd];
                [self drawWhenTouchMove:touches paintId:self.currentPaintingId];
            }
        }
    } else if (numOfFingerOn == 2 && lastPaintingEvent == PaintingEventDrawStart) {
        [self releaseRedoStack];
        [self applyLocalDrawingCmd];
        [self drawWhenTouchMove:touches paintId:self.currentPaintingId];
        
    } else if (numOfFingerOn == 2 && lastPaintingEvent != PaintingEventDrawStart) {

        if ([[touches allObjects] count] != 2) {
            gotMovement = YES;   
            UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
            float dx = [touch1 locationInView:self].x - [touch1 previousLocationInView:self].x;
            float dy = [touch1 locationInView:self].y - [touch1 previousLocationInView:self].y;        
            [self touchesMovedPan:CGSizeMake(dx, dy)];
            return;
        }
        
        gotMovement = YES;
        
        // The image is being zoomed in or out.
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        
        // metric: change in position of each finger
        float dx_a = [touch1 locationInView:self].x - [touch1 previousLocationInView:self].x;
        float dy_a = [touch1 locationInView:self].y - [touch1 previousLocationInView:self].y;
        float dx_b = [touch2 locationInView:self].x - [touch2 previousLocationInView:self].x;
        float dy_b = [touch2 locationInView:self].y - [touch2 previousLocationInView:self].y;
        
        // metric: distance between fingers
        CGFloat dist = [self distanceBetweenTwoPoints:[touch1 locationInView:self]
                                              toPoint:[touch2 locationInView:self]];
        CGFloat dist_last = [self distanceBetweenTwoPoints:[touch1 previousLocationInView:self]
                                                   toPoint:[touch2 previousLocationInView:self]];
        
        // metric: direction vector of each finger
        float v_a = atan2(dy_a, dx_a);
        float v_b = atan2(dy_b, dx_b);
        
        // If the fingers are moving in the same direction (difference in vectors is less than 45deg)
        // then we're working with a pan. Otherwise, they must be zooming.
        if (abs(v_a - v_b) < M_PI / 2){
            [self touchesMovedPan:CGSizeMake((dx_a + dx_b)/2, (dy_a + dy_b)/2)];
        } else {
            CGPoint center;
            // KONG: relatively depend on how far each finger moved
            center = [self centerZoomFromTouch1:[touch1 previousLocationInView:self]
                                     fromTouch2:[touch2 previousLocationInView:self]
                                       toTouch1:[touch1 locationInView:self]
                                       toTouch2:[touch2 locationInView:self]];
            
            [self touchesMovedZoomAtCenter:center newDistance:dist oldDistance:dist_last];
            
        }			
    } else if (numOfFingerOn == 1 && (lastPaintingEvent == PaintingEventZoom || lastPaintingEvent == PaintingEventPan)) {
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        float dx = [touch1 locationInView:self].x - [touch1 previousLocationInView:self].x;
        float dy = [touch1 locationInView:self].y - [touch1 previousLocationInView:self].y;        
        [self touchesMovedPan:CGSizeMake(dx, dy)];
    }
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    if (IS_IPAD) {
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        
        if (!layerInfo.offscreenLayerVisible) {
            return;
        }
    }

	[self finalizeTouch];
    
    // Hector: Pan/Zoom is disable
    if (![SettingManager sharedManager].isEnablePanZoom) {
        [self drawWhenTouchEnd:touches];
        return;
    }
    
	// Number of touches on the screen
	switch ([touches count]) {
		case 1: {
            if (!gotMovement && numOfFingerOn == 1) {
                for (UITouch *touch in touches) {
                    GSTouchData *touchData = [[GSTouchData alloc] init];
                    touchData.firstTouch = YES;
                    [touchDictionary setObject:touchData forKey:touch];
                }
                                
                isDrawingStroke = TRUE;
                
                CGPoint location = [[touches anyObject] locationInView:self];
                CGPoint start = CGPointMake(location.x, self.bounds.size.height - location.y);
                
                if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(startLineAtPoint:)]) {
                    [self.delegate startLineAtPoint:start];
                }
            
                lastPaintingEvent = PaintingEventDrawStart;
            }

            if (lastPaintingEvent == PaintingEventDrawStart) {
                [self drawWhenTouchEnd:touches];
            }
            
            firstDrawingPoint = NO;
            numOfFingerOn--;
            if (numOfFingerOn <= 0) {
                numOfFingerOn = 0;
                lastPaintingEvent = PaintingEventNone;
                gotMovement = NO;
                firstUITouch = nil;
            }
		} break;
        case 2: {
            numOfFingerOn -= 2;

            if (numOfFingerOn <= 0) {
                numOfFingerOn = 0;
            }
			//Get the first touch.
			UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
			UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
            
            if (touch1.tapCount == 2 && touch2.tapCount == 2) {
                DLog(@"Double taps with 2 fingers");
                
                // KONG: if zoom/pan is not in standard position/level then reset
                if ([self isNearStandardTransform] == NO) {
                    _lastZoom = self.transforms.zoom;
                    [self resetTransforms];
                    [self drawView];
                    
                } else {
                    // KONG: otherwise, zoom back to _lastZoom
                    CGPoint center = CGPointMake(([touch1 locationInView:self].x+[touch2 locationInView:self].x)/2,
                                                 ([touch1 locationInView:self].y+[touch2 locationInView:self].y)/2);
                    
                    [self touchesMovedZoomAtCenter:center newDistance:_lastZoom oldDistance:1.0];
                }
                
            }
            [self showZoomingLabel];

            lastPaintingEvent = PaintingEventNone;
            numOfFingerOn = 0; // safe defensive code ?!  coz we did numOfFingers -= 2 above            
            gotMovement = NO;
            firstUITouch = nil;
        } break;

        default:
            numOfFingerOn = 0;
            gotMovement = NO;
            lastPaintingEvent = PaintingEventNone;
            firstUITouch = nil;
            break;
	}    
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		[self processTouch:[touches anyObject]];
	}
	
	[self finalizeTouch];
	
	for (UITouch *touch in touches) {
		[touchDictionary removeObjectForKey:touch];
	}
    
    // just want to be save
    // this event happens when something pops up during drawing
    lastPaintingEvent = PaintingEventNone;
    numOfFingerOn = 0; 
    gotMovement = NO;
    firstUITouch = nil;
    isDrawingStroke = NO;
}

#pragma mark - Draw View
- (void)drawView {
    [super drawView];
    
    if (extDrawingView) {
        [extDrawingView drawView];
    }
}

- (void)drawViewNoExternal {
    [super drawView];
}

#pragma mark - Layers Control (Add/Remove/Move)
// For layer adding/removing, we don't support undo redo.
// However, we still need to adjust the undo redo stack and BURbuffer so that
// it should work probably
// This is the process for removing layer
// 1. remove strokes on layer to be removed
// 2. change strokes.layerIndexes to the new updated layer indexs
- (BOOL)removeLayer:(int)index {
    if (self.numOfLayers <= 1) {
        return NO;
    }
    
    if (index == 0) {
        return NO;
    }
    
    NSMutableArray * cmdToBeRemovedArray = [NSMutableArray array];
    
    for (PaintingCmd * cmd in undoSequenceArray) {
        if (cmd.layerIndex == index) {
            [cmdToBeRemovedArray addObject:cmd];
        }
        
        if (cmd.layerIndex > index) {
            cmd.layerIndex--;
        }
    }
    [undoSequenceArray removeObjectsInArray:cmdToBeRemovedArray];
    [cmdToBeRemovedArray removeAllObjects];
    
    for (PaintingCmd * cmd in redoSequenceArray) {
        if (cmd.layerIndex == index) {
            [cmdToBeRemovedArray addObject:cmd];
        }
        
        if (cmd.layerIndex > index) {
            cmd.layerIndex--;
        }
    }
    [redoSequenceArray removeObjectsInArray:cmdToBeRemovedArray];
    [cmdToBeRemovedArray removeAllObjects];

    return [super removeLayer:index];
}

- (void)moveLayerAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2 {
    [super moveLayerAtIndex:index1 toIndex:index2];
    // TODO: adjust undo commands here
    if (index1 < index2) {
        
        for (int i = 0; i < [undoSequenceArray count]; i++) {
            PaintingCmd * cmd = [undoSequenceArray objectAtIndex:i];
            if (cmd.layerIndex == index1) {
                cmd.layerIndex = index2;
            } else if (cmd.layerIndex > index1 && cmd.layerIndex <= index2) {
                cmd.layerIndex--;
            }
        }
        
        for (int i = 0; i < [redoSequenceArray count]; i++) {
            PaintingCmd * cmd = [redoSequenceArray objectAtIndex:i];
            if (cmd.layerIndex == index1) {
                cmd.layerIndex = index2;
            } else if (cmd.layerIndex > index1 && cmd.layerIndex <= index2) {
                cmd.layerIndex--;
            }
        }
        
    } else if (index1 > index2) {
        for (int i = 0; i < [undoSequenceArray count]; i++) {
            PaintingCmd * cmd = [undoSequenceArray objectAtIndex:i];
            if (cmd.layerIndex == index1) {
                cmd.layerIndex = index2;
            } else if (cmd.layerIndex >= index2 && cmd.layerIndex < index1) {
                cmd.layerIndex++;
            }
        }
        
        for (int i = 0; i < [redoSequenceArray count]; i++) {
            PaintingCmd * cmd = [redoSequenceArray objectAtIndex:i];
            if (cmd.layerIndex == index1) {
                cmd.layerIndex = index2;
            } else if (cmd.layerIndex >= index2 && cmd.layerIndex < index1) {
                cmd.layerIndex++;
            }
        }
    }
}

- (void)clearLayer:(int)layerIndex {
    int tempLayerIndex = currentLayerIndex;
    currentLayerIndex = layerIndex;
    
    [self setOffscreenFramebuffer];
    
    // Clear the buffer
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self setBackingUndoRedoFramebuffer];
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self drawView];
    currentLayerIndex = tempLayerIndex;
    
    [self transferToPaintingView:self.extDrawingView];
}

#define SAVE_CLEAR 0
- (void)erase {
    not_run_when_in_background
    
	if (extDrawingView) {
		[extDrawingView erase];
	}
	[super erase];
    
#if SAVE_CLEAR
    [self addClearUndoCommand:currentLayerIndex];
#else
    [undoSequenceArray removeAllObjects];
    [redoSequenceArray removeAllObjects];
    
    glPushMatrix();
    glLoadIdentity();
    glPopMatrix();
#endif
}

- (void)addClearUndoCommand:(int)layer {
    ClearPaintingCmd * cmd = [[ClearPaintingCmd alloc] init];
    cmd.layerIndex = layer;
    [self pushCommandToUndoStack:cmd];
    currentCmd = nil;
}

#pragma mark - Undo Stroke
- (BOOL)checkUndo {
    return [undoSequenceArray count] > 0;
}

- (BOOL)undoStroke {
    BOOL status = [self performUndo];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneUndo:)]) {
        [self.delegate doneUndo:[undoSequenceArray count]];
    }
    
    return status;
}

- (BOOL)performUndo {
    if ([self checkUndo] == NO) {
        return NO;
    } 

    [EAGLContext setCurrentContext:self.context];
    
    int tempCurrentLayerIndex = currentLayerIndex;
    
    glLoadIdentity();
    glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
    glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
    
    // Clear the current offscreen buffer
    for (int i = 0; i < self.numOfLayers; i++) {
        currentLayerIndex = i;
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);    
        
        glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Then load the backing undo redo buffer
        [self renderBackingUndoRedoTexture];
    }
    
    // Check the undo sequence array, load all painting command except the last command - the one which is removed
    // due to undo action
    for (int i = 0; i < [undoSequenceArray count]-1; i++) {
        PaintingCmd * cmd = [undoSequenceArray objectAtIndex:i];
        currentLayerIndex = cmd.layerIndex;
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);    
        
        [cmd doPaintingAction];
    }
        
    currentLayerIndex = tempCurrentLayerIndex;
    
    PaintingCmd * lastUndoCmd = [undoSequenceArray lastObject];
    
    [self setFramebuffer];    
    [self drawView];
    
    [self transferToPaintingView:self.extDrawingView];
    
	// Push to redo stack
	[self pushCommandToRedoStack:lastUndoCmd];
	
	[undoSequenceArray removeLastObject];
    [self applyLocalDrawingCmd];

 	return [self checkUndo];
}

// Undo procedure for drawing across layers
// 1. each stroke keeps info of: color, brush size, points, layer index the stroke belongs to
// 2. back undo redo buffer (BUR buffer) keeps an index that refers to the current layer index
- (void)pushCommandToUndoStack:(PaintingCmd *)cmd {
    currentCmd = cmd;
	[undoSequenceArray addObject:cmd];
    
	if ([undoSequenceArray count] > kUndoMaxBuffer) {
        
        PaintingCmd * cmd = [undoSequenceArray objectAtIndex:0];
        int tempCurrentLayer = currentLayerIndex;
        
        glPushMatrix();
        glLoadIdentity();
        currentLayerIndex = cmd.layerIndex;
        [self setBackingUndoRedoFramebuffer];
        glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
        glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
        [cmd doPaintingAction];
        glPopMatrix();
        
        currentLayerIndex = tempCurrentLayer;
        
        [undoSequenceArray removeObjectAtIndex:0];
	}
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(checkUndo:)]) {
        [self.delegate checkUndo:[undoSequenceArray count]];
    }
}

#pragma mark - Redo Stroke
- (BOOL)checkRedo {
    return [redoSequenceArray count] > 0;
}

- (BOOL)redoStroke {
    BOOL status = [self performRedo];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneRedo:)]) {
        [self.delegate doneRedo:[undoSequenceArray count]];
    }
    
    return status;
}

- (BOOL)performRedo {
    if ([self checkRedo] == NO) {
        return NO;
    }
	
    [EAGLContext setCurrentContext:self.context];
    
    // Add the last command from redo sequence to undo sequence before rendering
    PaintingCmd * lastRedoCmd = [redoSequenceArray lastObject];
    [undoSequenceArray addObject:lastRedoCmd];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(checkUndo:)]) {
        [self.delegate checkUndo:[undoSequenceArray count]];
    }

    int tempCurrentLayerIndex = currentLayerIndex;
    
    glLoadIdentity();
    glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
    glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
    
    // Clear the current offscreen buffer
    for (int i = 0; i < self.numOfLayers; i++) {
        currentLayerIndex = i;
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);    
        
        glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Then load the backing undo redo buffer
        [self renderBackingUndoRedoTexture];
    }
    
    // Check the undo sequence array, load all painting command
    for (int i = 0; i < [undoSequenceArray count]; i++) {
        PaintingCmd * cmd = [undoSequenceArray objectAtIndex:i];
        currentLayerIndex = cmd.layerIndex;
        //        [self setOffscreenFramebuffer];
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);    
        
        [cmd doPaintingAction];
    }
    currentLayerIndex = tempCurrentLayerIndex;
    
    // Remove the last redo command
    [redoSequenceArray removeLastObject];
    
    [self setFramebuffer];    
	[self drawView];
	[self transferToPaintingView:self.extDrawingView];
    [self applyLocalDrawingCmd];
   	return [self checkRedo];
}

- (void)pushCommandToRedoStack:(PaintingCmd *)cmd {
    not_run_when_in_background
	[redoSequenceArray addObject:cmd];
	if ([redoSequenceArray count] > kUndoMaxBuffer) {
        [redoSequenceArray removeObjectAtIndex:0];
	}
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(checkRedo:)]) {
        [self.delegate checkRedo:[redoSequenceArray count]];
    }
}

- (void)releaseRedoStack {
    not_run_when_in_background
	[redoSequenceArray removeAllObjects];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(checkRedo:)]) {
        [self.delegate checkRedo:[redoSequenceArray count]];
    }
}

#pragma mark - Swipe Gesture
#define kEnableSwipeGesture 0
// For Gestures
// Returns YES if the touch may be part of a valid gesture
//         NO  otherwise
// This allows us to buffer touches that may be part of a valid gesture,
// and only draw the points when we confirm it's invalid
- (BOOL)processTouch:(UITouch *)touch {
#if kEnableSwipeGesture
	if (!isPegged) {
		// default to YES, then invalidate it
		BOOL shouldPeg = YES;
		
		if (gestureStartX == kInvalidCoord) {
			gestureStartX = [touch locationInView:self].x;
			shouldPeg = NO;
		} else {
			if (fabs(gestureStartX-[touch locationInView:self].x) > 14) {
				// x deviated more than 14
				shouldPeg = NO;
				gestureStartX = kInvalidCoord;
			}
		}
		
		CGFloat y = [touch locationInView:self].y;
		if (gestureStartY == kInvalidCoord) {
			if (y > 410) { // 390
				gestureStartY = y;
			}
			shouldPeg = NO;
		} else {
			if ((gestureStartY-[touch locationInView:self].x) < 40) { // y > 370
				// y hasn't gotten low enough yet
				shouldPeg = NO;
			}
		}
		
		if (shouldPeg) {
			// all tests passed
			isPegged = YES;
		}
	}
	
	if (isPegged) {
        
	}
#endif
	
	return NO;
}

// Returns YES if the touch was a valid gesture
//         NO  otherwise
- (BOOL)finalizeTouch {
	if (IS_IPAD) {
        if (viewTransform.zoom <= 0.8f) {
            [self reset];
        }
    }
#if kEnableSwipeGesture
	gestureStartX = kInvalidCoord;
	gestureStartY = kInvalidCoord;
	isPegged = NO;
#endif
	
	return NO;
}

#pragma mark - Zoom Label
// KONG: get rounder  percentage value of number
- (int)roundUpPercent:(CGFloat)number {
    int percent = (int) (self.transforms.zoom * 100);
    
    int roundedPercent = (percent + 5) /10 * 10;
    return roundedPercent;
}

- (void)showZoomingLabel {
    int offset = ([UIApplication sharedApplication].statusBarHidden == TRUE) ? 20 : 0;
    CGFloat originY = -10 + offset;
    
    if (IS_IPAD) {
        originY += _zoomOffsetFromTop;
    }
    
    if (_zoomLabel == nil) {
        CGFloat originX = (self.frame.size.width - 80)/2;
        _zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 80, 30)];
        _zoomLabel.textAlignment = NSTextAlignmentCenter;
        _zoomLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _zoomLabel.layer.cornerRadius = 8;
        _zoomLabel.layer.borderWidth = 2;
        _zoomLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _zoomLabel.textColor = [UIColor whiteColor];
        _zoomLabel.font = [UIFont boldSystemFontOfSize:14];
        _zoomLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
    } else {
        // KONG: will set hidden again, so cancel current timer
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(hideZoomingLabel)
                                                   object:nil];
    }
    
    if (_zoomLabel.frame.origin.y != originY) {
        CGRect newFrame = _zoomLabel.frame;
        newFrame.origin.y = originY;
        _zoomLabel.frame = newFrame;
    }
    
    _zoomLabel.hidden = NO;
    _zoomLabel.text = [NSString stringWithFormat:@"  %d%%", [self roundUpPercent:self.transforms.zoom]];
    
    [self performSelector:@selector(hideZoomingLabel) withObject:nil afterDelay:1];
    
}

- (void)hideZoomingLabel {
    _zoomLabel.hidden = YES;
}

#pragma mark - Multitouch & Gestures
- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    return sqrt(x * x + y * y);
}

- (void)reset {
    [self resetTransforms];
    [self drawView];
    self.hidden = NO;
    self.transform = CGAffineTransformIdentity;
    viewTransform.zoom = 1;
}

- (CGPoint)pointWithOutCameraEffect:(CGPoint)location {
    location.x -= self.transforms.x;
    location.y -= self.transforms.y;
    
    // KONG: 3 transformation:
    // move from bottom-left to center
    // scale
    // move from center back to bottom-left
    location.x = (location.x - screenSize_.width/2)/self.transforms.zoom + screenSize_.width/2;
    location.y = (location.y - screenSize_.height/2)/self.transforms.zoom + screenSize_.height/2;
    return location;
}

- (CGPoint)pointWithCameraEffect:(CGPoint)location {
    //KONG: 3 transformation:
    // move from bottom-left to center
    // scale
    // move from center back to bottom-left
    location.x = (location.x - screenSize_.width/2) * self.transforms.zoom + screenSize_.width/2;
    location.y = (location.y - screenSize_.height/2) * self.transforms.zoom + screenSize_.height/2;
    
    location.x += self.transforms.x;
    location.y += self.transforms.y;
    
    return location;
}

#pragma mark - Pan/Zoom
#define kFloatPrecise 0.1f
- (void)resetTransforms {
    [super resetTransforms];
    if(extDrawingView) {
        [extDrawingView resetTransforms];
    }
    _actualTransform = self.transforms;
    viewTransform = self.transforms;
}

- (BOOL)isZoomNearStandard {
    return (fabs(self.transforms.zoom - 1.0) < 0.03);
}

- (BOOL)isPanNearStandard {
    return (fabs(self.transforms.x) < 10 &&
            fabs(self.transforms.y) < 10);
}
- (BOOL)isNearStandardTransform {
    return ([self isZoomNearStandard]
            && [self isPanNearStandard]);
}

- (void)setPanWithVector:(CGSize)vector {
    _actualTransform.x += vector.width;
    _actualTransform.y += vector.height;
    
    if (_actualTransform.x < - screenSize_.width * _actualTransform.zoom/2) {
        _actualTransform.x = - screenSize_.width * _actualTransform.zoom/2;
    }
    
    if (_actualTransform.y < - screenSize_.height * _actualTransform.zoom/2) {
        _actualTransform.y = - screenSize_.height * _actualTransform.zoom/2;
    }
    
    if (_actualTransform.x > screenSize_.width * _actualTransform.zoom/2) {
        _actualTransform.x = screenSize_.width * _actualTransform.zoom/2;
    }
    
    if (_actualTransform.y > screenSize_.height * _actualTransform.zoom/2) {
        _actualTransform.y = screenSize_.height * _actualTransform.zoom/2;
    }
    
    Transforms tempTransforms = self.transforms;
    
    tempTransforms.x = _actualTransform.x;
    tempTransforms.y = _actualTransform.y;
    self.transforms = tempTransforms;
    
    if ([self isPanNearStandard]) {
        tempTransforms.x = 0;
        tempTransforms.y = 0;
        self.transforms = tempTransforms;
    }
}

- (void)setZoomWithScale:(CGFloat)scale {
    _actualTransform.zoom *= scale;
    if (IS_IPAD) {
        if (_actualTransform.zoom < kZoomMinScale) {
            viewTransform.zoom *= scale;
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, viewTransform.zoom, viewTransform.zoom);
            return;
            
        } else if (_actualTransform.zoom > kZoomMaxScale) {
            _actualTransform.zoom = kZoomMaxScale;
        }
        
    } else {
        if (_actualTransform.zoom < kZoomMinScale) {
            _actualTransform.zoom = kZoomMinScale;
        } else if (_actualTransform.zoom > kZoomMaxScale) {
            _actualTransform.zoom = kZoomMaxScale;
        }
    }
    
    Transforms tempTransforms = self.transforms;
    tempTransforms.zoom = _actualTransform.zoom;
    self.transforms = tempTransforms;
    
    if ([self isZoomNearStandard]) {
        tempTransforms.zoom = 1.0;
        self.transforms = tempTransforms;
    }
}

- (void)touchesMovedPan:(CGSize)displacedRect {
    [self setPaintingEvent:PaintingEventPan hasPotientialConfiction:YES];
    //    DLog(@"PAN -> (%f, %f)", displacedRect.width, displacedRect.height);
    [self setPanWithVector:displacedRect];
    [self drawView];
}

- (void)touchesMovedZoom:(CGFloat)dist oldDistance:(CGFloat)dist_last {
    
    [self setZoomWithScale:(dist/dist_last)];
    [self showZoomingLabel];
    
    //    DLog(@"ZOOM -> %f %%", transforms.zoom);
    
    [self drawView];
}

- (void)touchesMovedZoomAtCenter:(CGPoint)center newDistance:(CGFloat)dist oldDistance:(CGFloat)dist_last {
    
    // A -> A'
    // A_w, A__t: coordination of A, A' with window
    // A_d: coordination of A, A' with drawing (after scale)
    // A_t: coordination of A, A' with texture
    
    // Transformation: A_w -> A_d -> A_t -> A__t -> A__d -> A__w
    // After zooming, my point A is displayed at A' which is moved from A a distant AA'
    // I need to move back to make it looks like I'm zooming at a fixed point A
    
    [self setPaintingEvent:PaintingEventZoom hasPotientialConfiction:YES];
    
    CGFloat nextScale = (dist/dist_last);
    
    //KONG: avoid zooming and panning to center point when in zooming limition
    if ((self.transforms.zoom == kZoomMaxScale && nextScale > 1) ||
        (self.transforms.zoom == kZoomMinScale && nextScale < 1)) {
        return;
    }
    
    CGPoint A_w = center;
    
    //KONG: remove camera effect to get real point in texture
    CGPoint A_d = [self pointWithOutCameraEffect:A_w];
    
    CGPoint A_t = [self convertToGL:A_d];
    
    
    //KONG: after zooming, what coordination my center will be? (coordinate with origin at bottom-left view)
    CGPoint A__t;
    
    //KONG: texture zoom at it origin (bottom-left),
    // and it will be display with center is center of screen (see how I draw texture in FB2GLView)
    // we move to center of display before scale then move back
    // we use the formular to change from coordinate of drawing view to coordinate of displaying
    A__t.x = (A_t.x - self.kTextureDisplaySizeWidth/2)*(dist/dist_last) + self.kTextureDisplaySizeWidth/2;
    A__t.y = (A_t.y - self.kTextureDisplaySizeHeight/2)*(dist/dist_last) + self.kTextureDisplaySizeHeight/2;
    
    CGPoint A__d = [self oppositeWithConvertToGL:A__t];
    CGPoint A__w = [self pointWithCameraEffect:A__d];
    
    //KONG: moving destinate to fingers point: A__w -> A_w
    [self setPanWithVector:CGSizeMake((A_w.x - A__w.x), (A_w.y - A__w.y))];
    
    [self touchesMovedZoom:dist oldDistance:dist_last];
}

//KONG: point in view coordination
- (CGPoint)centerZoomFromTouch1:(CGPoint)fromTouch1 fromTouch2:(CGPoint)fromTouch2 toTouch1:(CGPoint)toTouch1 toTouch2:(CGPoint)toTouch2 {
    CGPoint c; //center
    
    //KONG: zooming from a, b (fromTouch1, fromTouch2) to A, B (toTouch1, toTouch2)
    // vab is a vector from a to b
    
    CGPoint vaA = CGPointMake(toTouch1.x  - fromTouch1.x, toTouch1.y - fromTouch1.y);
    CGPoint vbB = CGPointMake(toTouch2.x  - fromTouch2.x, toTouch2.y - fromTouch2.y);
    
    if (fabs(vaA.x) < kFloatPrecise && fabs(vaA.y) < kFloatPrecise) {
        //        DLog(@"zoom at touch 1");
        return fromTouch1;
    }
    
    if (fabs(vbB.x) < kFloatPrecise && fabs(vbB.y) < kFloatPrecise) {
        //        DLog(@"zoom at touch 2");
        return fromTouch2;
    }
    
    CGPoint vab = CGPointMake(fromTouch2.x  - fromTouch1.x, fromTouch2.y - fromTouch1.y);
    
    // KONG: center c is calculated relatively, depending on how far each finger moved
    // vca/vcb = vaA/vbB
    // => vca/(vcb - vca) = vaA/(vbB - vaA)
    // => vca/vab = vaA/vbB_aA = vaA * vbB_aA/ (vbB_aA)^2 = k
    
    CGPoint vbB_aA = CGPointMake(vbB.x - vaA.x, vbB.y - vaA.y);
    
    float k = (vaA.x * vbB_aA.x + vaA.y * vbB_aA.y) / (vbB_aA.x * vbB_aA.x + vbB_aA.y * vbB_aA.y);
    
    // vca = k * vab
    // c_x = a_x - k * vab_x
    c = CGPointMake(fromTouch1.x - k * vab.x, fromTouch1.y - k * vab.y);
    
    return c;
}

#pragma mark - Transformation
- (void)setTransforms:(Transforms)t {
    internal_transforms = t;
    if (extDrawingView) {
        // NAM: rotation here
        Painting *me = [[PaintingManager sharedManager] getPainting:nil];
        Painting *ext = [[PaintingManager sharedManager] getPainting:kExternalScreen];
        // ext = me;
        // CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
        CGFloat * pos = (CGFloat *)malloc(2 * sizeof(CGFloat));
        pos[0] = t.x;
        pos[1] = t.y;
        CGFloat k = [ext getSuitableRotated90Ratio:me];
        t.y = -pos[0] * k * 1.0f;
        t.x = +pos[1] * k * 1.0f;
        extDrawingView.internal_transforms = t;
    }
}

- (Transforms)transforms {
    return internal_transforms;
}

#pragma mark - Supports
- (CGRect)getBoundingOfDrawingUpdateFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    CGPoint touchStart = CGPointMake(start.x, self.bounds.size.height-start.y);
    CGPoint touchEnd = CGPointMake(end.x, self.bounds.size.height-end.y);
    
    if (CGPointEqualToPoint(self.topLeftBounding, CGPointZero)) {
        self.topLeftBounding = touchStart;
    }
    
    if (CGPointEqualToPoint(self.bottomRightBounding, CGPointZero)) {
        self.bottomRightBounding = touchStart;
    }
    
    CGPoint topLeft = self.topLeftBounding;
    CGPoint bottomRight = self.bottomRightBounding;
    
    float pointSize = 0;
    glGetFloatv(GL_POINT_SIZE, &pointSize);
    float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)]?[[UIScreen mainScreen] scale]:1;
    pointSize = pointSize/scale;
    
    if (touchStart.x-pointSize/2 < self.topLeftBounding.x) {
        topLeft.x = touchStart.x-pointSize/2;
    }
    
    if (touchStart.x+pointSize/2 > self.bottomRightBounding.x) {
        bottomRight.x = touchStart.x+pointSize/2;
    }
    
    if (touchStart.y-pointSize/2 < self.topLeftBounding.y) {
        topLeft.y = touchStart.y-pointSize/2;
    }
    
    if (touchStart.y+pointSize/2 > self.bottomRightBounding.y) {
        bottomRight.y = touchStart.y+pointSize/2;
    }
    
    if (touchEnd.x-pointSize/2 < self.topLeftBounding.x) {
        topLeft.x = touchEnd.x-pointSize/2;
    }
    
    if (touchEnd.x+pointSize/2 > self.bottomRightBounding.x) {
        bottomRight.x = touchEnd.x+pointSize/2;
    }
    
    if (touchEnd.y-pointSize/2 < self.topLeftBounding.y) {
        topLeft.y = touchEnd.y-pointSize/2;
    }
    
    if (touchEnd.y+pointSize/2 > self.bottomRightBounding.y) {
        bottomRight.y = touchEnd.y+pointSize/2;
    }
    self.topLeftBounding = topLeft;
    self.bottomRightBounding = bottomRight;
    
    return CGRectMake(topLeft.x, topLeft.y, bottomRight.x-topLeft.x, bottomRight.y-topLeft.y);
}

void CGAffineToGL2(const CGAffineTransform *t, GLfloat *m)
{
    // | m[0] m[4] m[8]  m[12] |     | m11 m21 m31 m41 |     | a c 0 tx |
    // | m[1] m[5] m[9]  m[13] |     | m12 m22 m32 m42 |     | b d 0 ty |
    // | m[2] m[6] m[10] m[14] | <=> | m13 m23 m33 m43 | <=> | 0 0 1  0 |
    // | m[3] m[7] m[11] m[15] |     | m14 m24 m34 m44 |     | 0 0 0  1 |
    
    m[2] = m[3] = m[6] = m[7] = m[8] = m[9] = m[11] = m[14] = 0.0f;
    m[10] = m[15] = 1.0f;
    m[0] = t->a; m[4] = t->c; m[12] = t->tx;
    m[1] = t->b; m[5] = t->d; m[13] = t->ty;
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"opengl_frame"];
    if ([undoSequenceArray count]) {
        NSMutableArray *cmdDicts = [NSMutableArray arrayWithCapacity:[undoSequenceArray count]];
        for (int i = 0; i < [undoSequenceArray count]; i++) {
            PaintingCmd *cmd = [undoSequenceArray objectAtIndex:i];
            NSDictionary *cmdDict = [cmd saveToDict];
            [cmdDicts addObject:cmdDict];
        }
        [dict setObject:cmdDicts forKey:@"opengl_undo_array"];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (MainPaintingView *)loadFromDict:(NSDictionary *)dict {
    MainPaintingView *drawingView = [[MainPaintingView alloc] initWithDict:dict];
    NSArray *cmdDicts = [dict objectForKey:@"opengl_undo_array"];
    for (int i = 0; i < [cmdDicts count]; i++) {
        NSDictionary *cmdDict = [cmdDicts objectAtIndex:i];
        PaintingCmd *cmd = [PaintingCmd loadFromDict:cmdDict];
        [drawingView pushCommandToUndoStack:cmd];
        drawingView.currentPaintingId = cmd.uid;
    }
    return drawingView;
}

- (void)reloadView {	
    [EAGLContext setCurrentContext:self.context];
    
    int tempCurrentLayerIndex = currentLayerIndex;
    
    glLoadIdentity();
    glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
    glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
    
    // Clear the current offscreen buffer
    for (int i = 0; i < self.numOfLayers; i++) {
        currentLayerIndex = i;
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
        
        glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Then load the backing undo redo buffer
        [self renderBackingUndoRedoTexture];
    }
    
    // Check the undo sequence array, load all painting command
    for (int i = 0; i < [undoSequenceArray count]; i++) {
        PaintingCmd * cmd = [undoSequenceArray objectAtIndex:i];
        currentLayerIndex = cmd.layerIndex;
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
        
        [cmd doPaintingAction];
    }
    
    currentLayerIndex = tempCurrentLayerIndex;
    
    [self setFramebuffer];
    [self drawView];
    
    [self transferToPaintingView:self.extDrawingView];
	
    [self applyLocalDrawingCmd];
}

@end
