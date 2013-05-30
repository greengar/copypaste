//
//  TextView.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "TextView.h"
#import "PlaceHolderTextView.h"

@interface TextView()
@property (nonatomic, strong) PlaceHolderTextView *textView;
@end

@implementation TextView
@synthesize textView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.textView setBackgroundColor:[UIColor clearColor]];
        [self.textView setTextColor:[UIColor darkGrayColor]];
        [self.textView setFont:[UIFont systemFontOfSize:17.0f]];
        [self.textView setDelegate:self];
        [self.textView setPlaceHolderText:@"Enter Text"];
        [self addSubview:self.textView];
    }
    return self;
}

- (UIView *)contentView {
    return self.textView;
}
@end
