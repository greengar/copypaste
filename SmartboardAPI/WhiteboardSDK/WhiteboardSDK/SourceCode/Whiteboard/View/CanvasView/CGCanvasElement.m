//
//  CGCanvasElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CGCanvasElement.h"
#import "SettingManager.h"
#import "GSButton.h"

@interface CGCanvasElement()
@property (nonatomic, strong) CGPaintingView *drawingView;
@end

@implementation CGCanvasElement
@synthesize drawingView = _drawingView;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.drawingView = [[CGPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            frame.size.width,
                                                                            frame.size.height)];
        [self addSubview:self.drawingView];
    }
    return self;
}

- (UIView *)contentView {
    return self.drawingView;
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"CGCanvasElement" forKey:@"element_type"];
//    [dict setObject:[self.drawingView saveToDict] forKey:@"element_drawing"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    CGCanvasElement *canvasElement = [[CGCanvasElement alloc] initWithDict:dictionary];
    return canvasElement;
    return nil;
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
