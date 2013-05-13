//
//  CPFullProfileViewController.m
//  copypaste
//
//  Created by Hector Zhao on 5/1/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPFullProfileViewController.h"
#import "DataManager.h"
#import <Smartboard/GSTheme.h>

#define kNavigationBarHeight 66
#define kOffset 8
#define kTopOffset kNavigationBarHeight+kOffset
#define kAvatarSize 76
#define kTextOffsetLeft kOffset+kAvatarSize+kOffset
#define kTextWidth self.view.frame.size.width-kTextOffsetLeft+kOffset
#define kTextHeight 30

@interface CPFullProfileViewController ()

@end

@implementation CPFullProfileViewController
@synthesize profileUser = _profileUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = kCPBackgroundColor;
        
        CPNavigationView *navigationView = [[CPNavigationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kNavigationBarHeight)
                                                                           hasBack:YES
                                                                           hasDone:NO];
        navigationView.delegate = self;
        [self.view addSubview:navigationView];
    }
    return self;
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setProfileUser:(CPUser *)profileUser {
    _profileUser = profileUser;
    
    EGOImageView *userAvatarImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    [userAvatarImageView setFrame:CGRectMake(kOffset,
                                             kTopOffset,
                                             kAvatarSize,
                                             kAvatarSize)];
    [userAvatarImageView setDelegate:self];
    [userAvatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    [userAvatarImageView setClipsToBounds:YES];
    if (self.profileUser.isAvatarCached) {
        [userAvatarImageView setImage:self.profileUser.avatarImage];
    } else {
        [userAvatarImageView setImageURL:[NSURL URLWithString:self.profileUser.avatarURLString]];
    }
    [self.view addSubview:userAvatarImageView];
    
	UILabel *profileUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kTopOffset,
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileUsernameLabel.backgroundColor = [UIColor clearColor];
    profileUsernameLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileUsernameLabel.textColor = [UIColor whiteColor];
    profileUsernameLabel.text = [self.profileUser displayName];
    [self.view addSubview:profileUsernameLabel];
    
    UILabel *profileDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kTopOffset+kTextHeight+kOffset,
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileDistanceLabel.backgroundColor = [UIColor clearColor];
    profileDistanceLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileDistanceLabel.textColor = [UIColor whiteColor];
    profileDistanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [self.profileUser distanceStringToUser:[[GSSession activeSession] currentUser]]];
    [self.view addSubview:profileDistanceLabel];
    
    self.profileSentMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                kTopOffset+2*(kTextHeight+kOffset),
                                                                                kTextWidth,
                                                                                kTextHeight)];
    self.profileSentMsgNumLabel.backgroundColor = [UIColor clearColor];
    self.profileSentMsgNumLabel.font = DEFAULT_FONT_SIZE(15.0f);
    self.profileSentMsgNumLabel.textColor = [UIColor whiteColor];
    self.profileSentMsgNumLabel.text = [NSString stringWithFormat:@"Sent: %d", [self.profileUser numOfCopyFromMe]];
    [self.view addSubview:self.profileSentMsgNumLabel];
    
    UILabel *profileReceiveMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                   kTopOffset+3*(kTextHeight+kOffset),
                                                                                   kTextWidth,
                                                                                   kTextHeight)];
    profileReceiveMsgNumLabel.backgroundColor = [UIColor clearColor];
    profileReceiveMsgNumLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileReceiveMsgNumLabel.textColor = [UIColor whiteColor];
    profileReceiveMsgNumLabel.text = [NSString stringWithFormat:@"Received: %d", [self.profileUser numOfPasteToMe]];
    [self.view addSubview:profileReceiveMsgNumLabel];
    
    UILabel *profileLastSeenLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kTopOffset+4*(kTextHeight+kOffset),
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileLastSeenLabel.backgroundColor = [UIColor clearColor];
    profileLastSeenLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileLastSeenLabel.textColor = [UIColor whiteColor];
    profileLastSeenLabel.text = [NSString stringWithFormat:@"Last: %@", [self.profileUser lastSeenTimeString]];
    [self.view addSubview:profileLastSeenLabel];
    
    if (self.profileUser.isFacebookUser) {
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [facebookButton setFrame:CGRectMake(kOffset, kTopOffset+kAvatarSize+kOffset, kAvatarSize, kAvatarSize)];
        [facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
        [facebookButton addTarget:self
                           action:@selector(facebookButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:facebookButton];
    }
    
    UIButton *pasteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pasteButton setFrame:CGRectMake(kOffset, kTopOffset+5*(kTextHeight+kOffset), self.view.frame.size.width-2*kOffset, 44)];
    [pasteButton setTitle:@"paste" forState:UIControlStateNormal];
    [pasteButton addTarget:self action:@selector(pasteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pasteButton];
}

- (void)pasteButtonTapped:(id)sender {
    [[DataManager sharedManager] pasteToUser:self.profileUser
                                       block:^(BOOL succeed, NSError *error) {
                                           self.profileSentMsgNumLabel.text = [NSString stringWithFormat:@"Sent: %d", [self.profileUser numOfCopyFromMe]];
                                       }];
}

@end
