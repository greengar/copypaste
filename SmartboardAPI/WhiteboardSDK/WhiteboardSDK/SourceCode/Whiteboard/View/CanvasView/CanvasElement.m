//
//  CanvasElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CanvasElement.h"
#import "SettingManager.h"
#import "GSButton.h"

@interface CanvasElement()
@property (nonatomic, strong) MainPaintingView *drawingView;
@property (nonatomic) UIView *previewAreaView;
@property (nonatomic, strong) UIImageView *screenshotImageView;
@end

@implementation CanvasElement
@synthesize drawingView = _drawingView;
@synthesize previewAreaView = _previewAreaView;
@synthesize screenshotImageView = _screenshotImageView;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        self.allowToEdit = NO;
        self.allowToMove = YES;
        self.allowToSelect = YES;
        
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


- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.allowToEdit = YES;
        self.allowToMove = NO;
        self.allowToSelect = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        // OpenGL View
        self.drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              frame.size.width,
                                                                              frame.size.height)];
        [self addSubview:self.drawingView];
        [self.drawingView initialDrawing];
        if (image) {
            [self.drawingView loadFromSavedPhotoAlbum:image];
            [self.drawingView addCurrentImageToUndoRedoSpace];
        }
        
        [self initControlWithFrame:frame];
        
    }
    return self;
}

- (void)initControlWithFrame:(CGRect)frame {
    self.previewAreaView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.drawingView setTopLeftBounding:CGPointZero];
    [self.drawingView setBottomRightBounding:CGPointZero];
    [self addSubview:self.previewAreaView];
    [self.previewAreaView setBackgroundColor:[UIColor clearColor]];
    [self.previewAreaView setUserInteractionEnabled:NO];
    [self.previewAreaView.layer setBorderWidth:1];
    [self.previewAreaView.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"Whiteboard.bundle/DottedImage.png"]] CGColor]];
}

- (UIView *)contentView {
    return self.drawingView;
}

- (void)finishCanvasView {
    [self deselect];
}

- (void)select {
    [super select];
    [self setAllowToEdit:YES];
    [self setAllowToMove:NO];
    [self setAllowToSelect:NO];
    [self.previewAreaView.layer setBorderWidth:2];
    [self removeScreenshot];
}

- (void)deselect {
    [super deselect];
    [self setAllowToEdit:NO];
    [self setAllowToMove:YES];
    [self setAllowToSelect:YES];
    [self.previewAreaView.layer setBorderWidth:0];
    [self setTransform:self.currentTransform];
    
    BOOL successful = !CGRectEqualToRect(self.previewAreaView.frame, CGRectZero);
    if (successful) {
        [self takeScreenshot];
    }
    if (self.elementCreated == NO) {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementCreated:successful:)]) {
            [self.delegate elementCreated:self successful:successful];
        }
    } else {
        
    }
    self.elementCreated = YES;
}

- (void)setAllowToSelect:(BOOL)allowToSelect {
    [super setAllowToSelect:allowToSelect];
}

- (void)setAllowToMove:(BOOL)allowToMove {
    [super setAllowToMove:allowToMove];
    
    if (self.allowToMove) {
        [self.drawingView setUserInteractionEnabled:NO];
        
    } else {
        [self.drawingView setUserInteractionEnabled:YES];
    }
}

- (void)setAllowToEdit:(BOOL)allowToEdit {
    [super setAllowToEdit:allowToEdit];
    
    if (self.allowToEdit) {
        // For the Canvas View, it should always be full screen
        if ([self superview]) {
            [self resetTransform];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.allowToEdit) {
        return [super hitTest:point withEvent:event];
    } else {
        UIView *hitView = [super hitTest:point withEvent:event];
        if (hitView == self && CGRectContainsPoint(self.previewAreaView.frame, point)) {
            return hitView;
        }
        return nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.previewAreaView.frame, location)) {
        return YES;
    }
    return NO;
}

- (void)elementTap:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self];
    if (CGRectContainsPoint(self.previewAreaView.frame, location)) {
        [super elementTap:(UITapGestureRecognizer *)tapGesture];
    }
}

- (void)updateBoundingRect:(CGRect)boundingRect {
    self.previewAreaView.frame = boundingRect;
}

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
    [dict setObject:@"CanvasElement" forKey:@"element_type"];
    [dict setObject:[self.drawingView saveToDict] forKey:@"element_drawing"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    CanvasElement *canvasElement = [[CanvasElement alloc] initWithDict:dictionary];
    return canvasElement;
}

#pragma mark - Undo/Redo
- (void)checkUndo:(int)undoCount {
    
}

- (void)checkRedo:(int)redoCount {
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
