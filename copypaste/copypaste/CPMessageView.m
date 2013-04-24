//
//  CPMessageView.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPMessageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CPMessageView
@synthesize message = _message;
@synthesize userAvatarImageView = _userAvatarImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backgroundImageView.backgroundColor = [UIColor whiteColor];
        backgroundImageView.layer.cornerRadius = 5;
        backgroundImageView.clipsToBounds = YES;
        [self addSubview:backgroundImageView];
        
        self.userAvatarImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        self.userAvatarImageView.backgroundColor = [UIColor grayColor];
        self.userAvatarImageView.layer.cornerRadius = 3;
        self.userAvatarImageView.clipsToBounds = YES;
        [self addSubview:self.userAvatarImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 200, 30)];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.textColor = [UIColor blackColor];
        [self addSubview:self.usernameLabel];
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setFrame:CGRectMake(0, 400, 106, 60)];
        [self addSubview:saveButton];
        
        UIButton *remindMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [remindMeButton setTitle:@"Remind me later" forState:UIControlStateNormal];
        [remindMeButton addTarget:self action:@selector(remindMeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [remindMeButton setFrame:CGRectMake(107, 400, 106, 60)];
        [self addSubview:remindMeButton];
        
        UIButton *discardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [discardButton setTitle:@"Discard" forState:UIControlStateNormal];
        [discardButton addTarget:self action:@selector(discardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [discardButton setFrame:CGRectMake(214, 400, 106, 60)];
        [self addSubview:discardButton];
    }
    return self;
}

- (void)addMessageContent:(CPMessage *)message {
    self.message = message;
    [self.userAvatarImageView setImageURL:[NSURL URLWithString:message.sender.avatarURLString]];
    [self.usernameLabel setText:[NSString stringWithFormat:@"Sender: %@", message.sender.fullname]];
    if ([message.messageContent isKindOfClass:[NSString class]]) {
        // Init the text view here
    } else if ([message.messageContent isKindOfClass:[UIImage class]]) {
        // Init the scroll view with the image here
    }
}

- (void)showMeOnView:(UIView *)view {
    [view addSubview:self];
}

- (void)saveButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(saveMessage:)]) {
        [self.delegate saveMessage:self.message];
    }
}

- (void)remindMeButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(remindMessage:)]) {
        [self.delegate remindMessage:self.message];
    }
}

- (void)discardButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(discardMessage:)]) {
        [self.delegate discardMessage:self.message];
    }
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}
@end
