//
//  CPPasteboardView.h
//  copypaste
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPasteboardView : UIView <UIScrollViewDelegate, UITextViewDelegate>

- (void)updateUIWithPasteObject:(NSObject *)objectFromClipboard;

@property (nonatomic, retain) UIImageView *pasteboardBackgroundImageView;
@property (nonatomic, retain) UIImageView *pasteboardHeaderImageView;
@property (nonatomic, retain) UITextView *pasteboardTextView;
@property (nonatomic, retain) UIScrollView *pasteboardImageHolderView;
@property (nonatomic, retain) UIImageView *pasteboardImageView;

@end
