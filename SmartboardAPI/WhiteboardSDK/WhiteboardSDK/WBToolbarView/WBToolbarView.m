//
//  WBToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBToolbarView.h"
#import "WBCanvasToolbarView.h"
#import "WBBottomRightToolbarView.h"

@implementation WBToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // for debugging
        //self.backgroundColor = [UIColor yellowColor];
        
        float leftMargin = 25;
        WBCanvasToolbarView *canvasToolbarView = [[WBCanvasToolbarView alloc] initWithFrame:CGRectMake(leftMargin, 0, self.frame.size.width / 2 + 50 - leftMargin, self.frame.size.height)];
        canvasToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:canvasToolbarView];
        
        float x = canvasToolbarView.frame.origin.x + canvasToolbarView.frame.size.width;
        WBBottomRightToolbarView *bottomRightToolbarView = [[WBBottomRightToolbarView alloc] initWithFrame:CGRectMake(x, canvasToolbarView.frame.origin.y, self.frame.size.width - x, self.frame.size.height)];
        bottomRightToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:bottomRightToolbarView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
