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
- (void)shareMessage:(CPMessage *)message;
- (void)copyMessage:(CPMessage *)message;
- (void)discardMessage:(CPMessage *)message;
@end

@interface CPMessageView : UIView <EGOImageViewDelegate, UIScrollViewDelegate, UITextViewDelegate>

- (id)initWithFrame:(CGRect)frame message:(CPMessage *)message controller:(UIViewController *)baseController;
- (void)showMeOnView:(UIView *)view;

@property (nonatomic, strong) CPMessage *message;
@property (nonatomic, strong) EGOImageView *userAvatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) CPTextView *pasteboardTextView;
@property (nonatomic, strong) UIScrollView *pasteboardImageHolderView;
@property (nonatomic, strong) UIImageView *pasteboardImageView;
@property (nonatomic, assign) id<CPMessageViewDelegate> delegate;
@property (nonatomic, strong) UIViewController *baseViewController;
@property (nonatomic, strong) UIDocumentInteractionController *viewController;

@end
