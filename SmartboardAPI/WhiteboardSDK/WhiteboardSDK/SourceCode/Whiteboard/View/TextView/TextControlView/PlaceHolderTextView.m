//
//  PlaceHolderTextView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "PlaceHolderTextView.h"
#import "TextElement.h"

@interface PlaceHolderTextView()
@property (nonatomic, strong) UITextView *placeHolderTextView;
@end
@implementation PlaceHolderTextView
@synthesize placeHolderTextView = _placeHolderLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentOffset = CGPointZero;
        self.contentInset = UIEdgeInsetsZero;
        self.scrollEnabled = NO;
        
        self.placeHolderTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.placeHolderTextView setTextColor:[UIColor lightGrayColor]];
        [self.placeHolderTextView setUserInteractionEnabled:NO];
        [self.placeHolderTextView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.placeHolderTextView];
        [self sendSubviewToBack:self.placeHolderTextView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (void)textChanged {
    if ([self.text length] == 0) {
        [self.placeHolderTextView setHidden:NO];
    } else {
        [self.placeHolderTextView setHidden:YES];
    }
    self.contentOffset = CGPointZero;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.contentSize.width, self.contentSize.height);
}

- (CGPoint)contentOffset {
    return CGPointZero;
}

- (UIEdgeInsets)contentInset {
    return UIEdgeInsetsZero;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self.placeHolderTextView setFont:font];
}

- (void)setPlaceHolderText:(NSString *)placeHolderText {
    [self.placeHolderTextView setFont:self.font];
    [self.placeHolderTextView setText:placeHolderText];
}

@end
