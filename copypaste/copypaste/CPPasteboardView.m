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
#define kPasteboardMinimumHeight (IS_IPHONE5 ? 338 : 250)
#define kClipboardHeaderOffset 9
#define kPasteboardContentTopOffset (1+kClipboardHeaderOffset)
#define kPasteboardContentBottomOffset (1+kClipboardHeaderOffset)
#define kPasteboardContentWidth 300
#define kPasteboardEmptyContentTopGap 30

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
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        
        // The "pasteboard" string content
        self.pasteboardTextView = [[CPTextView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               frame.size.width,
                                                                               frame.size.height)];
        self.pasteboardTextView.backgroundColor = [UIColor clearColor];
        self.pasteboardTextView.textColor = [UIColor whiteColor];
        self.pasteboardTextView.textAlignment = UITextAlignmentCenter;
        self.pasteboardTextView.editable = NO;
        self.pasteboardTextView.font = DEFAULT_FONT_SIZE(16.0f);
        self.pasteboardTextView.hidden = YES;
        self.pasteboardTextView.layer.cornerRadius = 3;
        self.pasteboardTextView.clipsToBounds = YES;
        self.pasteboardTextView.delegate = self;
        self.pasteboardTextView.bounces = YES;
        self.pasteboardTextView.alwaysBounceVertical = YES;
        [self addSubview:self.pasteboardTextView];
        
        // The "pasteboard" image scroll view
        self.pasteboardImageHolderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                        0,
                                                                                        frame.size.width,
                                                                                        frame.size.height)];
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
        
    }
    return self;
}

- (void)updateUIWithPasteObject:(NSObject *)objectFromClipboard {
    if ([objectFromClipboard isKindOfClass:[NSString class]]) {
        self.pasteboardTextView.hidden = NO;
        [self.pasteboardTextView setText:((NSString *) objectFromClipboard)];
        
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
        
    } else {
        self.pasteboardTextView.hidden = NO;
        [self.pasteboardTextView setText:@"Your clipboard is empty, please copy something to paste here!\nYou can copy images, texts,\nwebs or files."];
        [self.pasteboardTextView setContentOffset:CGPointMake(0, -kPasteboardEmptyContentTopGap)];
    }
}

@end
