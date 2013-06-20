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

@interface GLCanvasElement()
@property (nonatomic, strong) MainPaintingView *drawingView;
@property (nonatomic) UIView *previewAreaView;
@property (nonatomic, strong) UIImageView *screenshotImageView;
@end

@implementation GLCanvasElement
@synthesize drawingView = _drawingView;
@synthesize previewAreaView = _previewAreaView;
@synthesize screenshotImageView = _screenshotImageView;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {        
        self.backgroundColor = [UIColor clearColor];
        
        // OpenGL Dict
        NSDictionary *drawingDict = [dictionary objectForKey:@"element_drawing"];
        
        // OpenGL View
        self.drawingView = [MainPaintingView loadFromDict:drawingDict];
        [self addSubview:self.drawingView];
        UIImage *image = nil;
        [self.drawingView initialDrawing];
        if (image) {
            [self.drawingView loadFromSavedPhotoAlbum:image];
            [self.drawingView addCurrentImageToUndoRedoSpace];
        }
        [self.drawingView reloadView];
        
        [self initControlWithFrame:self.defaultFrame];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // OpenGL View
        self.drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              frame.size.width,
                                                                              frame.size.height)];
        [self addSubview:self.drawingView];
        [self.drawingView setDelegate:self];
        [self.drawingView initialDrawing];
        [self initControlWithFrame:frame];
        
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
    return self.drawingView;
}

- (void)finishCanvasView {
    [self deselect];
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
    self.screenshotImageView = [[UIImageView alloc] initWithFrame:self.drawingView.frame];
    self.screenshotImageView.image = [self.drawingView takeScreenshot];
    [self addSubview:self.screenshotImageView];
    [self sendSubviewToBack:self.screenshotImageView];
}

- (void)removeScreenshot {
    [self.screenshotImageView removeFromSuperview];
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"GLCanvasElement" forKey:@"element_type"];
    [dict setObject:[self.drawingView saveToDict] forKey:@"element_drawing"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithDict:dictionary];
    return canvasElement;
}

#pragma mark - Undo/Redo
- (void)addedCommandToUndoPool {
    [[HistoryManager sharedManager] addActionBrushElement:self forPage:(WBPage *)self.superview];
}

- (void)checkUndo:(int)undoCount {
    
}

- (void)checkRedo:(int)redoCount {
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
