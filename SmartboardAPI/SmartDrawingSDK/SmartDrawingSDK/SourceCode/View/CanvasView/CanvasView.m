//
//  CanvasView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CanvasView.h"
#import "SettingManager.h"
#import "GSButton.h"

#define kUndoPickerWidth 69
#define kURButtonWidthHeight 64
@interface CanvasView()
@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UIButton *redoButton;
@property (nonatomic, strong) MainPaintingView *drawingView;
@property (nonatomic, strong) ColorTabView *colorTabView;
@property (nonatomic, strong) ColorPickerView *colorPickerView;
@property (nonatomic, strong) GSButton *doneButton;
@end

@implementation CanvasView
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize drawingView = _drawingView;
@synthesize colorTabView = _colorTabView;
@synthesize colorPickerView = _colorPickerView;
@synthesize doneButton = _doneButton;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.allowToEdit = YES;
        self.allowToMove = NO;
        self.allowToSelect = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        // OpenGL View
        self.drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.drawingView setDelegate:self];
        [self addSubview:self.drawingView];
        
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.drawingView initialDrawing];
            if (image) {
                [self.drawingView loadFromSavedPhotoAlbum:image];
                [self.drawingView addCurrentImageToUndoRedoSpace];
            }
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
        
        self.doneButton = [GSButton buttonWithType:UIButtonTypeRoundedRect themeStyle:GreenButtonStyle];
        [self.doneButton setFrame:CGRectMake(0, frame.size.height-44, frame.size.width/5, 44)];
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(finishCanvasView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
    }
    return self;
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
}

- (void)deselect {
    [super deselect];
    [self setAllowToEdit:NO];
    [self setAllowToMove:YES];
    [self setAllowToSelect:YES];
}

- (void)setAllowToSelect:(BOOL)allowToSelect {
    [super setAllowToSelect:allowToSelect];
}

- (void)setAllowToMove:(BOOL)allowToMove {
    [super setAllowToMove:allowToMove];
    
    if (self.allowToMove) {
        [self.undoButton setHidden:YES];
        [self.redoButton setHidden:YES];
        [self.colorTabView setHidden:YES];
        [self.colorPickerView setHidden:YES];
        [self.doneButton setHidden:YES];
        [self.drawingView setUserInteractionEnabled:NO];
        
    } else {
        [self.undoButton setHidden:NO];
        [self.redoButton setHidden:NO];
        [self.colorTabView setHidden:NO];
        [self.colorPickerView setHidden:NO];
        [self.doneButton setHidden:NO];
        [self.drawingView setUserInteractionEnabled:YES];
    }
}

- (void)setAllowToEdit:(BOOL)allowToEdit {
    [super setAllowToEdit:allowToEdit];
    if (self.allowToEdit) {
        // For the Canvas View, it should always be full screen
        if ([self superview]) {
            self.frame = CGRectMake(0, 0, [self superview].frame.size.width, [self superview].frame.size.height);
        }
    }
}

- (void)selectColorTabAtIndex:(int)index {
    [self.colorPickerView selectColorTabAtIndex:index];
}

- (void)showHidePicker {
    if ([self.colorPickerView alpha] == 0.0f) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
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
        [UIView setAnimationDelegate:self];
        self.colorPickerView.alpha = 0.0f;
        self.colorPickerView.frame = CGRectMake(0,
                                                self.frame.size.height-kLauncherHeight,
                                                self.colorTabView.frame.size.width,
                                                self.colorPickerView.frame.size.height);
        [UIView commitAnimations];
    }
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
