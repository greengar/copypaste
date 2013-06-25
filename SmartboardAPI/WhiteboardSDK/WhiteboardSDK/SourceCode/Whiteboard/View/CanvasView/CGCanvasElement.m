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
