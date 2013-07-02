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

@interface CGCanvasElement() {
    CGPaintingView *drawingView;
}
@end

@implementation CGCanvasElement

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        drawingView = [[CGPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       frame.size.width,
                                                                       frame.size.height)];
        [self addSubview:drawingView];
    }
    return self;
}

- (UIView *)contentView {
    return drawingView;
}

- (UIView *)contentDrawingView {
    return drawingView;
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"CGCanvasElement" forKey:@"element_type"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
    // Nothing to do honestly
}

@end
