//
//  CPProfileViewController.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPProfileViewController.h"
#import "GSSSession.h"

#define kOffset 8
#define kAvatarSize 88
#define kTextOffsetLeft kOffset+kAvatarSize+kOffset
#define kTextWidth self.view.frame.size.width-kTextOffsetLeft+kOffset
#define kTextHeight 30

@interface CPProfileViewController ()

@end

@implementation CPProfileViewController
@synthesize profileUser = _profileUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    profileUsernameLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    profileUsernameLabel.text = self.profileUser.fullname;
    [self.view addSubview:profileUsernameLabel];
    
    UILabel *profileDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                              kOffset+kTextHeight+kOffset,
                                                                              kTextWidth,
                                                                              kTextHeight)];
    profileDistanceLabel.backgroundColor = [UIColor clearColor];
    profileDistanceLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    profileDistanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [self.profileUser distanceStringToUser:[[GSSSession activeSession] currentUser]]];
    [self.view addSubview:profileDistanceLabel];
    
    UILabel *profileSentMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                kOffset+2*(kTextHeight+kOffset),
                                                                                kTextWidth,
                                                                                kTextHeight)];
    profileSentMsgNumLabel.backgroundColor = [UIColor clearColor];
    profileSentMsgNumLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    profileSentMsgNumLabel.text = [NSString stringWithFormat:@"Sent: %d", [self.profileUser numOfCopyFromMe]];
    [self.view addSubview:profileSentMsgNumLabel];
    
    UILabel *profileReceiveMsgNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextOffsetLeft,
                                                                                   kOffset+3*(kTextHeight+kOffset),
                                                                                   kTextWidth,
                                                                                   kTextHeight)];
    profileReceiveMsgNumLabel.backgroundColor = [UIColor clearColor];
    profileReceiveMsgNumLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    profileReceiveMsgNumLabel.text = [NSString stringWithFormat:@"Receive: %d", [self.profileUser numOfPasteToMe]];
    [self.view addSubview:profileReceiveMsgNumLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
