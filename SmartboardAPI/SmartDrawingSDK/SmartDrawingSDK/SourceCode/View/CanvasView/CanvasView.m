//
//  CanvasView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CanvasView.h"
#import "SettingManager.h"

#define kUndoPickerWidth 69
#define kURButtonWidthHeight 64

@implementation CanvasView
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize drawingView = _drawingView;
@synthesize colorTabView = _colorTabView;
@synthesize colorPickerView = _colorPickerView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // OpenGL View
        self.drawingView = [[MainPaintingView alloc] initWithFrame:frame];
        [self.drawingView setDelegate:self];
        [self addSubview:self.drawingView];
        
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.drawingView initialDrawing];
            [self.drawingView loadFromSavedPhotoAlbum:image];
            [self.drawingView addCurrentImageToUndoRedoSpace];
        });
        
        // Bottom color tabs
        self.colorTabView = [[ColorTabView alloc] initWithFrame:CGRectMake(0,
                                                                           frame.size.height-kLauncherHeight,
                                                                           frame.size.width,
                                                                           kLauncherHeight)];
        [self.colorTabView setDelegate:self];
        [self addSubview:self.colorTabView];
        
        // Color Picker
        self.colorPickerView = [[ColorPickerView alloc] initWithFrame:CGRectMake(0,
                                                                                 frame.size.height-kLauncherHeight-kColorPickerViewHeight,
                                                                                 frame.size.width,
                                                                                 kColorPickerViewHeight)];
        [self.colorPickerView setDelegate:self];
        [self addSubview:self.colorPickerView];
        
        // Undo and Redo
        [self initializeUndoRedoButtonsWithFrame:frame];
    }
    return self;
}

- (void)selectColorTabAtIndex:(int)index {
    [self.colorPickerView selectColorTabAtIndex:index];
}

- (void)showHidePicker {
    if ([self.colorPickerView alpha] == 0.0f) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(finishShowHidePickerAnimation)];
        [UIView setAnimationDelegate:self];
        self.colorPickerView.alpha = 1.0f;
        self.colorPickerView.frame = CGRectMake(0,
                                                self.frame.size.height-kLauncherHeight-kColorPickerViewHeight,
                                                self.colorTabView.frame.size.width,
                                                self.colorPickerView.frame.size.height);
        [UIView commitAnimations];
        
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(finishShowHidePickerAnimation)];
        [UIView setAnimationDelegate:self];
        self.colorPickerView.alpha = 0.0f;
        self.colorPickerView.frame = CGRectMake(0,
                                                self.frame.size.height-kLauncherHeight,
                                                self.colorTabView.frame.size.width,
                                                self.colorPickerView.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)finishShowHidePickerAnimation {
    [self.colorTabView finishShowHidePicker:(self.colorPickerView.alpha == 1.0f)];
}

- (void)updateSelectedColor {
    [self.colorTabView updateColorTab];
}

#pragma mark - Undo and Redo buttons
- (void)initializeUndoRedoButtonsWithFrame:(CGRect)frame {
    self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.undoButton.frame = CGRectMake(0, 0, kURButtonWidthHeight, kURButtonWidthHeight);
    self.undoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.undoButton addTarget:self action:@selector(undoButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.undoButton addTarget:self action:@selector(undoButtonTouchDown)
              forControlEvents:UIControlEventTouchDown];
    [self.undoButton addTarget:self action:@selector(undoButtonDragExit)
              forControlEvents:UIControlEventTouchDragExit];
    [self.undoButton addTarget:self action:@selector(undoButtonDragEnter)
              forControlEvents:UIControlEventTouchDragEnter];
    [self.undoButton setImage:[UIImage imageNamed:@"SmartDrawing.bundle/URUndoButton.png"]
                     forState:UIControlStateNormal];
    [self addSubview:self.undoButton];
    [self.undoButton setTitle:@"0" forState:UIControlStateNormal];
    
    self.redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redoButton.frame = CGRectMake(frame.size.width-kURButtonWidthHeight,
                                       0,
                                       kURButtonWidthHeight,
                                       kURButtonWidthHeight);
    self.redoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.redoButton addTarget:self action:@selector(redoButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.redoButton addTarget:self action:@selector(redoButtonTouchDown)
              forControlEvents:UIControlEventTouchDown];
    [self.redoButton addTarget:self action:@selector(redoButtonDragExit)
              forControlEvents:UIControlEventTouchDragExit];
    [self.redoButton addTarget:self action:@selector(redoButtonDragEnter)
              forControlEvents:UIControlEventTouchDragEnter];
    [self.redoButton setImage:[UIImage imageNamed:@"SmartDrawing.bundle/URRedoButton.png"]
                     forState:UIControlStateNormal];
    [self addSubview:self.redoButton];
    
    [self updateBar];
}

- (void) undoButtonTapped {
    [self.drawingView undoStroke];
    [self updateBar];
}

- (void) undoButtonTouchDown {
    if ([self.drawingView checkUndo]) {
        self.undoButton.alpha = 0.5;
    }
}

- (void) undoButtonDragExit {
    if ([self.drawingView checkUndo]) {
        self.undoButton.alpha = 1.0;
    }
}

- (void) undoButtonDragEnter {
    if ([self.drawingView checkUndo]) {
        self.undoButton.alpha = 0.5;
    }
}

- (void) redoButtonTapped {
    [self.drawingView redoStroke];
    [self updateBar];
}

- (void) redoButtonTouchDown {
    if ([self.drawingView checkRedo]) {
        self.redoButton.alpha = 0.5;
    }
}

- (void) redoButtonDragExit {
    if ([self.drawingView checkRedo]) {
        self.redoButton.alpha = 1.0;
    }
}

- (void) redoButtonDragEnter {
    if ([self.drawingView checkRedo]) {
        self.redoButton.alpha = 0.5;
    }
}

- (void) updateBar {
    if (![self.drawingView checkUndo]) {
        self.undoButton.alpha = 0.2;
    } else {
        self.undoButton.alpha = 1.0;
    }
    
    if (![self.drawingView checkRedo]) {
        self.redoButton.alpha = 0.2;
    } else {
        self.redoButton.alpha = 1.0;
    }
}

- (void)checkUndo:(int)undoCount {
    [self updateBar];
}

- (void)checkRedo:(int)redoCount {
    [self updateBar];
}

@end
