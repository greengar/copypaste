//
//  CPShortProfileViewController.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPShortProfileViewController.h"
#import <Smartboard/Smartboard.h>

#define kOffset 8
#define kAvatarSize 76
#define kTextOffsetLeft kOffset+kAvatarSize+kOffset
#define kTextWidth self.view.frame.size.width-kTextOffsetLeft+kOffset
#define kTextHeight 30

@interface CPShortProfileViewController ()

@end

@implementation CPShortProfileViewController
@synthesize profileUser = _profileUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = kCPBackgroundColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EGOImageView *userAvatarImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(kOffset,
                                                                                       kOffset,
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
                                                                              kOffset,
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileUsernameLabel.backgroundColor = [UIColor clearColor];
    profileUsernameLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileUsernameLabel.textColor = [UIColor whiteColor];
    if (self.profileUser.fullname) {
        profileUsernameLabel.text = self.profileUser.fullname;
    } else {
        profileUsernameLabel.text = self.profileUser.username;
    }
    [self.view addSubview:profileUsernameLabel];
    
    UILabel *profileDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kOffset+kTextHeight+kOffset,
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileDistanceLabel.backgroundColor = [UIColor clearColor];
    profileDistanceLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileDistanceLabel.textColor = [UIColor whiteColor];
    profileDistanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [self.profileUser distanceStringToUser:[[GSSession activeSession] currentUser]]];
    [self.view addSubview:profileDistanceLabel];
    
    UILabel *profileSentMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                kOffset+2*(kTextHeight+kOffset),
                                                                                kTextWidth,
                                                                                kTextHeight)];
    profileSentMsgNumLabel.backgroundColor = [UIColor clearColor];
    profileSentMsgNumLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileSentMsgNumLabel.textColor = [UIColor whiteColor];
    profileSentMsgNumLabel.text = [NSString stringWithFormat:@"Sent: %d", [self.profileUser numOfCopyFromMe]];
    [self.view addSubview:profileSentMsgNumLabel];
    
    UILabel *profileReceiveMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                   kOffset+3*(kTextHeight+kOffset),
                                                                                   kTextWidth,
                                                                                   kTextHeight)];
    profileReceiveMsgNumLabel.backgroundColor = [UIColor clearColor];
    profileReceiveMsgNumLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileReceiveMsgNumLabel.textColor = [UIColor whiteColor];
    profileReceiveMsgNumLabel.text = [NSString stringWithFormat:@"Receive: %d", [self.profileUser numOfPasteToMe]];
    [self.view addSubview:profileReceiveMsgNumLabel];
    
    UILabel *profileLastSeenLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kOffset+4*(kTextHeight+kOffset),
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileLastSeenLabel.backgroundColor = [UIColor clearColor];
    profileLastSeenLabel.font = DEFAULT_FONT_SIZE(15.0f);
    profileLastSeenLabel.textColor = [UIColor whiteColor];
    profileLastSeenLabel.text = [NSString stringWithFormat:@"Last: %@", [self.profileUser lastSeenTimeString]];
    [self.view addSubview:profileLastSeenLabel];
    
    if (self.profileUser.isFacebookUser) {
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [facebookButton setFrame:CGRectMake(kOffset, kOffset+kAvatarSize+kOffset, kAvatarSize, kAvatarSize)];
        [facebookButton setTitle:@"f" forState:UIControlStateNormal];
        [facebookButton addTarget:self
                           action:@selector(facebookButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:facebookButton];
    }
}

- (void)facebookButtonTapped:(id)sender {
    NSString *facebookLink = [NSString stringWithFormat:@"https://www.facebook.com/%@", self.profileUser.facebookScreenName];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebookLink]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
