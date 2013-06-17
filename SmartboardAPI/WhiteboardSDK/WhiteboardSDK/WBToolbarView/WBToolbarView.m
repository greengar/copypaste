//
//  WBToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBToolbarView.h"
#import "WBCanvasToolbarView.h"

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
