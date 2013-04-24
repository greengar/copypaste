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

@protocol CPMessageViewDelegate
- (void)saveMessage:(CPMessage *)message;
- (void)remindMessage:(CPMessage *)message;
- (void)discardMessage:(CPMessage *)message;
@end

@interface CPMessageView : UIView <EGOImageViewDelegate>

- (void)addMessageContent:(CPMessage *)message;
- (void)showMeOnView:(UIView *)view;

@property (nonatomic, retain) CPMessage *message;
@property (nonatomic, retain) EGOImageView *userAvatarImageView;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, assign) id<CPMessageViewDelegate> delegate;

@end
