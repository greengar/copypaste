//
//  CPPasteboardView.m
//  copypaste
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPPasteboardView.h"
#import <QuartzCore/QuartzCore.h>

#define kOffset 6
#define kHeaderViewHeight 52
#define kPasteboardMinimumHeight 131
#define kPasteboardContentTopOffset 1 //22
#define kPasteboardContentBottomOffset 2
#define kPasteboardContentWidth 300
#define kPasteboardEmptyContentTopGap 30
#define kPasteboardTextContentTopGap 11
#define kPasteboardImageContentTopGap 17

@interface CPPasteboardView()

@end

@implementation CPPasteboardView
@synthesize pasteboardBackgroundImageView = _myPasteboardBackgroundImageView;
@synthesize pasteboardHeaderImageView = _pasteboardHeaderImageView;
@synthesize pasteboardTextView = _myPasteboardTextView;
@synthesize pasteboardImageHolderView = _myPasteboardImageHolderView;
@synthesize pasteboardImageView = _myPasteboardImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // The "my pasteboard background image view"
        self.pasteboardBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                           0,
                                                                                           frame.size.width,
                                                                                           frame.size.height)];
        self.pasteboardBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                                              | UIViewAutoresizingFlexibleHeight;
        self.pasteboardBackgroundImageView.image = [[UIImage imageNamed:@"pasteboard.png"] stretchableImageWithLeftCapWidth:30
                                                                                                            topCapHeight:30];
        [self addSubview:self.pasteboardBackgroundImageView];
        
        // The "pasteboard" string content
        self.pasteboardTextView = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width-kPasteboardContentWidth)/2,
                                                                                 kPasteboardContentTopOffset,
                                                                                 kPasteboardContentWidth,
                                                                                 kPasteboardMinimumHeight-kPasteboardContentTopOffset-kPasteboardContentBottomOffset)];
        self.pasteboardTextView.backgroundColor = [UIColor clearColor];
        self.pasteboardTextView.textColor = [UIColor whiteColor];
        self.pasteboardTextView.textAlignment = UITextAlignmentCenter;
        self.pasteboardTextView.editable = NO;
        self.pasteboardTextView.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        self.pasteboardTextView.hidden = YES;
        self.pasteboardTextView.layer.cornerRadius = 3;
        self.pasteboardTextView.clipsToBounds = YES;
        self.pasteboardTextView.delegate = self;
        [self addSubview:self.pasteboardTextView];
        
        // The "pasteboard" image scroller
        self.pasteboardImageHolderView = [[UIScrollView alloc] initWithFrame:CGRectMake((frame.size.width-kPasteboardContentWidth)/2,
                                                                                          kPasteboardContentTopOffset,
                                                                                          kPasteboardContentWidth,
                                                                                          kPasteboardMinimumHeight-kPasteboardContentTopOffset-kPasteboardContentBottomOffset)];
        self.pasteboardImageHolderView.backgroundColor = [UIColor clearColor];
        self.pasteboardImageHolderView.hidden = YES;
        self.pasteboardImageHolderView.layer.cornerRadius = 3;
        self.pasteboardImageHolderView.clipsToBounds = YES;
        self.pasteboardImageHolderView.delegate = self;
        [self addSubview:self.pasteboardImageHolderView];
        
        // The "pasteboard" image content
        self.pasteboardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.pasteboardImageHolderView.frame.size.width,
                                                                                 self.pasteboardImageHolderView.frame.size.height)];
        self.pasteboardImageView.backgroundColor = [UIColor clearColor];
        [self.pasteboardImageHolderView addSubview:self.pasteboardImageView];
        
        // The "pasteboard" header view
        self.pasteboardHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 22)];
        self.pasteboardHeaderImageView.image = [UIImage imageNamed:@"header-clipboard.fw.png"];
        [self addSubview:self.pasteboardHeaderImageView];
    }
    return self;
}

- (void)updateUIWithPasteObject:(NSObject *)objectFromClipboard {
    if ([objectFromClipboard isKindOfClass:[NSString class]]) {
        self.pasteboardTextView.hidden = NO;
        [self.pasteboardTextView setText:((NSString *) objectFromClipboard)];
        [self.pasteboardTextView setContentOffset:CGPointMake(0, -kPasteboardTextContentTopGap)];
        
    } else if ([objectFromClipboard isKindOfClass:[UIImage class]]) {
        self.pasteboardImageHolderView.hidden = NO;
        [self.pasteboardImageView setImage:((UIImage *) objectFromClipboard)];
        float imageWidth = ((UIImage *) objectFromClipboard).size.width;
        float imageHeight = ((UIImage *) objectFromClipboard).size.height*kPasteboardContentWidth/imageWidth;
        self.pasteboardImageView.frame = CGRectMake(self.pasteboardImageView.frame.origin.x,
                                                    self.pasteboardImageView.frame.origin.y,
                                                    self.pasteboardImageView.frame.size.width,
                                                    imageHeight);
        self.pasteboardImageHolderView.contentSize = CGSizeMake(self.pasteboardImageHolderView.frame.size.width,
                                                                imageHeight);
        [self.pasteboardImageHolderView setContentOffset:CGPointMake(0, -kPasteboardImageContentTopGap)];
        
    } else {
        self.pasteboardTextView.hidden = NO;
        [self.pasteboardTextView setText:@"Your clipboard is empty, please copy something to paste here!\nYou can copy images, texts,\nwebs or files."];
        [self.pasteboardTextView setContentOffset:CGPointMake(0, -kPasteboardEmptyContentTopGap)];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        [scrollView setDecelerationRate:0]; // Stop deceleration
        if (scrollView == self.pasteboardTextView) {
            [scrollView setContentOffset:CGPointMake(0, -kPasteboardTextContentTopGap) animated:YES];
        } else {
            [scrollView setContentOffset:CGPointMake(0, -kPasteboardImageContentTopGap) animated:YES];
        }
    }
}

@end
