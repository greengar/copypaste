//
//  PlaceHolderTextView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "PlaceHolderTextView.h"
#import "TextElement.h"

@interface PlaceHolderTextView() {
    BOOL allowToBecomeFirstResponder;
}

@property (nonatomic, strong) UITextView *placeHolderTextView;
@property (nonatomic) CGSize minTextSize;
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
        self.userInteractionEnabled = NO;
        allowToBecomeFirstResponder = YES;
        
        self.placeHolderTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.placeHolderTextView setTextColor:[UIColor lightGrayColor]];
        [self.placeHolderTextView setUserInteractionEnabled:NO];
        [self.placeHolderTextView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.placeHolderTextView];
        [self sendSubviewToBack:self.placeHolderTextView];
        [self setMinimumTextSize];
        
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
    CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(kTextViewMaxWidth, 100000) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = (textSize.width < self.minTextSize.width) ? self.minTextSize.width : textSize.width;
    textSize.height = (textSize.height < self.minTextSize.height) ? self.minTextSize.height : textSize.height;
    self.contentSize = CGSizeMake(textSize.width+30, textSize.height+15);
    self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    self.superview.transform = ((WBBaseElement *) self.superview).defaultTransform;
    self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.contentSize.width, self.contentSize.height);
    self.superview.transform = ((WBBaseElement *) self.superview).currentTransform;
}

- (void)revive {
    [self textChanged];
    self.clipsToBounds = NO;
    allowToBecomeFirstResponder = YES;
}

- (void)rest {
    if ([self.text length] == 0) {
        [self.placeHolderTextView setHidden:NO];
    } else {
        [self.placeHolderTextView setHidden:YES];
    }
    self.clipsToBounds = YES;
    allowToBecomeFirstResponder = NO;
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
    [self setMinimumTextSize];
}

- (void)setPlaceHolderText:(NSString *)placeHolderText {
    [self.placeHolderTextView setFont:self.font];
    [self.placeHolderTextView setText:placeHolderText];
    [self setMinimumTextSize];
}

- (void)setMinimumTextSize {
    self.minTextSize = [self.placeHolderTextView.text sizeWithFont:self.placeHolderTextView.font
                                                 constrainedToSize:CGSizeMake(kTextViewMaxWidth, 100000)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
}

- (BOOL)canBecomeFirstResponder {
    return allowToBecomeFirstResponder;
}

@end
