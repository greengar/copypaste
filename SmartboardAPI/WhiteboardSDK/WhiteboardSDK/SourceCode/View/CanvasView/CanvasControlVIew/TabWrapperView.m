//
//  TabWrapperView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 7/19/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "TabWrapperView.h"

@implementation TabWrapperView
@synthesize displayView =_displayView;
@synthesize eventView = _eventView;
@synthesize selected = _selected;

// I don't think this is used, but I'm leaving it here just in case -Elliot
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super init])) {
        // Initialization code
		self.displayView = [[GSColorCircle alloc] initWithFrame:CGRectMake(21, 11, 22, 23)];
        self.eventView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.eventView setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/SelectedTabBackground.png"]
                                  forState:UIControlStateNormal];
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        // color does not matter because it is always later overwritten by SettingManager
        // same for opacity and pointSize
		self.displayView = [[GSColorCircle alloc] initWithFrame:CGRectMake(21, 11, 22, 23) andColor:[UIColor blackColor] andOpacity:0.95 andPointSize:9.0];
        self.eventView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.eventView setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/SelectedTabBackground.png"]
                                  forState:UIControlStateNormal];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_selected) {
        [self.eventView setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/SelectedTabBackground.png"]
                                  forState:UIControlStateNormal];
    } else {
        [self.eventView setBackgroundImage:nil
                                  forState:UIControlStateNormal];
    }
}

@end
