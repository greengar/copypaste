//
//  PlaceHolderTextView.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "PlaceHolderTextView.h"

@interface PlaceHolderTextView()
@property (nonatomic, strong) UITextView *placeHolderLabel;
@end
@implementation PlaceHolderTextView
@synthesize placeHolderLabel = _placeHolderLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.placeHolderLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.placeHolderLabel setTextColor:[UIColor lightGrayColor]];
        [self.placeHolderLabel setUserInteractionEnabled:NO];
        [self addSubview:self.placeHolderLabel];
        [self sendSubviewToBack:self.placeHolderLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (void)textChanged {
    if ([self.text length] == 0) {
        [self.placeHolderLabel setHidden:NO];
    } else {
        [self.placeHolderLabel setHidden:YES];
    }
}

- (void)setPlaceHolderText:(NSString *)placeHolderText {
    [self.placeHolderLabel setFont:self.font];
    [self.placeHolderLabel setText:placeHolderText];
}

@end
