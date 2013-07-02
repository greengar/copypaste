//
//  CPPasteboardView.h
//  copypaste
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTextView.h"

@protocol CPPasteboardDelegate
- (void)finishInstruction;
@end

@interface CPPasteboardView : UIView <UIScrollViewDelegate, UITextViewDelegate>

- (void)showInstruction;
- (void)hideInstruction;
- (void)updateUIWithPasteObject:(NSObject *)objectFromClipboard;

@property (nonatomic, strong) UIButton *instructionButton;
@property (nonatomic, strong) UIImageView *pasteboardBackgroundImageView;
@property (nonatomic, strong) UIImageView *pasteboardHeaderImageView;
@property (nonatomic, strong) CPTextView *pasteboardTextView;
@property (nonatomic, strong) UIScrollView *pasteboardImageHolderView;
@property (nonatomic, strong) UIImageView *pasteboardImageView;
@property (nonatomic, assign) id<CPPasteboardDelegate> delegate;

@end
