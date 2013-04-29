//
//  CPMessageView.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "CPMessage.h"
#import "CPTextView.h"

@protocol CPMessageViewDelegate
@optional
- (void)saveMessage:(CPMessage *)message;
- (void)copyMessage:(CPMessage *)message;
- (void)discardMessage:(CPMessage *)message;
@end

@interface CPMessageView : UIView <EGOImageViewDelegate, UIScrollViewDelegate, UITextViewDelegate>

- (id)initWithFrame:(CGRect)frame message:(CPMessage *)message controller:(UIViewController *)controller;
- (void)showMeOnView:(UIView *)view;

@property (nonatomic, retain) CPMessage *message;
@property (nonatomic, retain) EGOImageView *userAvatarImageView;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *distanceLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) CPTextView *pasteboardTextView;
@property (nonatomic, retain) UIScrollView *pasteboardImageHolderView;
@property (nonatomic, retain) UIImageView *pasteboardImageView;
@property (nonatomic, assign) id<CPMessageViewDelegate> delegate;
@property (nonatomic, retain) UIViewController *viewController;

@end
