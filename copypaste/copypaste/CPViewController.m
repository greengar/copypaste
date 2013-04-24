//
//  CPViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Firebase/Firebase.h>
#import "GMGridViewLayoutStrategies.h"
#import "GSSParseQueryHelper.h"
#import "NSData+Base64.h"

#define kUserHolderWidth 102
#define kUserHolderHeight 128
#define kUserBackgroundWidth 102
#define kUserBackgroundHeight 128
#define kUserAvatarWidth 60
#define kUserAvatarHeight 60
#define kUserNameWidth 102
#define kUserNameHeight 20
#define kPasteWidth 102
#define kPasteHeight 48

#define kContentViewTag 777
#define kLabelViewTag 778
#define kPasteLabelViewTag 779

#define kOffset 6
#define kHeaderViewHeight 52
#define kPasteboardMinimumHeight (IS_IPHONE5 ? 175 : 131)

@interface CPViewController ()

@end

@implementation CPViewController
@synthesize myPasteboardHolderView = _myPasteboardHolderView;
@synthesize otherPasteboardHolderView = _otherPasteboardHolderView;
@synthesize settingButton = _settingButton;
@synthesize availableUsersGridView = _availableUsersGridView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The background of the whole screen
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (self.view.frame.size.height == 548) {
        backgroundImageView.image = [UIImage imageNamed:@"background-548h.png"];
    } else {
        backgroundImageView.image = [UIImage imageNamed:@"background.png"];
    }
    [self.view addSubview:backgroundImageView];
        
    // The header "copypaste"
    UIImageView *headerImageView = [[UIImageView alloc] init];
    UIImage *headerImage = [UIImage imageNamed:@"header.png"];
    headerImageView.frame = CGRectMake(kOffset, kOffset, self.view.frame.size.width-2*kOffset, kHeaderViewHeight);
    headerImageView.image = headerImage;
    [self.view addSubview:headerImageView];
    
    // The gear button which means "setting"
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingButton.frame = CGRectMake(262, 10, 44, 44);
    [self.settingButton setImage:[UIImage imageNamed:@"gear.png"]
                        forState:UIControlStateNormal];
    [self.settingButton addTarget:self
                           action:@selector(settingButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
    
    // The avatar image view of the logged in user
    self.avatarImageView = [[EGOImageView alloc] init];
    self.avatarImageView.frame = CGRectMake(10, 10, 43, 43);
    self.avatarImageView.image = [UIImage imageNamed:@"pasteboard.png"];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.layer.cornerRadius = 3;
    self.avatarImageView.clipsToBounds = YES;
    [self.view addSubview:self.avatarImageView];
    
    // The "my pasteboard holder view"
    self.myPasteboardHolderView = [[CPPasteboardView alloc] initWithFrame:CGRectMake(kOffset+2,
                                                                                     kOffset+kHeaderViewHeight+kOffset,
                                                                                     self.view.frame.size.width - 2*(kOffset+2),
                                                                                     kPasteboardMinimumHeight)];
    self.myPasteboardHolderView.backgroundColor = [UIColor clearColor];
    self.myPasteboardHolderView.layer.cornerRadius = 3;
    self.myPasteboardHolderView.clipsToBounds = YES;
    [self.view addSubview:self.myPasteboardHolderView];
        
    // The "other pasteboard holder view"
    self.otherPasteboardHolderView = [[CPPasteboardView alloc] initWithFrame:CGRectMake(kOffset+2,
                                                                                        kOffset+kHeaderViewHeight+kOffset+  kPasteboardMinimumHeight+kUserHolderHeight,
                                                                                        self.view.frame.size.width - 2*(kOffset+2),
                                                                                        kPasteboardMinimumHeight)];
    self.otherPasteboardHolderView.backgroundColor = [UIColor clearColor];
    self.otherPasteboardHolderView.layer.cornerRadius = 3;
    self.otherPasteboardHolderView.clipsToBounds = YES;
    [self.view addSubview:self.otherPasteboardHolderView];
        
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:kNotificationApplicationDidBecomeActive
                                               object:nil];
    
    self.availableUsersGridView = [[GMGridView alloc] initWithFrame:CGRectMake(kOffset,
                                                                               kOffset+kHeaderViewHeight+kOffset+self.myPasteboardHolderView.frame.size.height,
                                                                               self.view.frame.size.width-2*kOffset,
                                                                               kUserHolderHeight)];
    self.availableUsersGridView.dataSource = self;
    self.availableUsersGridView.actionDelegate = self;
    self.availableUsersGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    [self.view addSubview:self.availableUsersGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateUI];
    
    if ([GSSSession isAuthenticated]) {
        [self finishAuthentication];
    } else {
        [[GSSSession activeSession] authenticateSmartboardAPIFromViewController:self delegate:self];
    }
}

- (void)finishAuthentication {
    [[GSSSession activeSession] getNearbyUserWithDelegate:self];
    [[GSSSession activeSession] addObserver:self];
    [self updateUI];
}

- (void)updateUI {
    [self hideOldCopiedContent];
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    [self.myPasteboardHolderView updateUIWithPasteObject:itemToPaste];
        
    if ([GSSSession isAuthenticated]) {
        GSSUser *currentUser = [[GSSSession activeSession] currentUser];
        if ([currentUser isAvatarCached]) {
            [self.avatarImageView setImage:currentUser.avatarImage];
        } else if ([currentUser avatarURLString]) {
            [self.avatarImageView setImageURL:[NSURL URLWithString:currentUser.avatarURLString]];
            [self.avatarImageView setDelegate:self];
        } else {
            [self.avatarImageView setImage:nil];
        }
    }
    [self.availableUsersGridView reloadData];
}

- (void)settingButtonTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                        message:[NSString stringWithFormat:@"You have logged in as %@. Do you want to log out?", [[GSSSession activeSession] currentUserName]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Log Out", nil];
    [alertView show];
}

- (void)hideOldCopiedContent {
    self.myPasteboardHolderView.pasteboardTextView.hidden = YES;
    self.myPasteboardHolderView.pasteboardImageHolderView.hidden = YES;
}

- (void)didLoginSucceeded {
    [self dismissModalViewControllerAnimated:YES];
    [self finishAuthentication];
}

- (void)didLoginFailed:(NSError *)error {
    // I think we have nothing to do now
}

- (void)didGetNearbyUserSucceeded:(NSArray *)listOfUsers {
    if ([listOfUsers count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No nearby user"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        [[DataManager sharedManager] updateNearbyUsers:listOfUsers];
        [self updateUI];
    }
}

- (void)didGetNearbyUserFailed:(NSError *)error {

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[GSSSession activeSession] logOut];
        [self viewDidAppear:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Finish log out"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [[[DataManager sharedManager] availableUsers] count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(kUserHolderWidth, kUserHolderHeight);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView_ cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView_ dequeueReusableCellWithIdentifier:@"layerCell"];
    
    if(cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.clipsToBounds = YES;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    kUserBackgroundWidth,
                                                                                    kUserBackgroundHeight)];
        backgroundView.image = [UIImage imageNamed:@"person-background.png"];
        [cell addSubview:backgroundView];
        
        EGOImageView *contentView = [[EGOImageView alloc] initWithFrame:CGRectMake(21,
                                                                                   21,
                                                                                   kUserAvatarWidth,
                                                                                   kUserAvatarHeight)];
        contentView.tag = kContentViewTag;
        contentView.image = [UIImage imageNamed:@"pasteboard.png"];
        contentView.contentMode = UIViewContentModeScaleAspectFill;
        contentView.clipsToBounds = YES;
        contentView.delegate = self;
        [cell addSubview:contentView];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          kUserNameWidth,
                                                                          kUserNameHeight)];
        contentLabel.textAlignment = UITextAlignmentCenter;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        contentLabel.tag = kLabelViewTag;
        [cell addSubview:contentLabel];
        
        UIImageView *pasteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    kUserHolderHeight - kPasteHeight,
                                                                                    kPasteWidth,
                                                                                    kPasteHeight)];
        pasteImageView.backgroundColor = [UIColor clearColor];
        pasteImageView.tag = kPasteLabelViewTag;
        pasteImageView.image = [UIImage imageNamed:@"paste.png"];
        [cell addSubview:pasteImageView];
    }
    
    if ([[[DataManager sharedManager] availableUsers] count] == 0) {
        UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
        [contentLabel setText:@"No available user"];
        
    } else {
        GSSUser * user = [[[DataManager sharedManager] availableUsers] objectAtIndex:index];
        EGOImageView *contentView = (EGOImageView *) [cell viewWithTag:kContentViewTag];
        UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
        
        if (user != nil) {
            if (user.isAvatarCached) {
                [contentView setImage:user.avatarImage];
            } else if (user.avatarURLString) {
                [contentView setImageURL:[NSURL URLWithString:user.avatarURLString]];
                [contentView setDelegate:self];
            }
        }
        
        [contentLabel setText:user.fullname];
    }
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView_ didTapOnItemAtIndex:(NSInteger)position {
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    GSSUser * user = [[[DataManager sharedManager] availableUsers] objectAtIndex:position];
    if (itemToPaste) {
        [[GSSSession activeSession] sendMessage:itemToPaste toUser:user];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not paste"
                                                            message:[NSString stringWithFormat:@"Your clipboard is empty, please copy something to paste to %@!", user.fullname]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMessageFrom:(NSString *)userId
                      content:(NSObject *)messageContent
                         time:(NSDate *)time {
    GSSUser *user = [[DataManager sharedManager] userById:userId];
    
    CPMessage *newMessage = [[CPMessage alloc] init];
    [newMessage setSender:user];
    [newMessage setMessageContent:messageContent];
    [newMessage setCreatedDateInterval:[time timeIntervalSince1970]];
    DLog(@"Message: %@", newMessage);
    [[[DataManager sharedManager] receivedMessages] addObject:newMessage];
    
    [self.otherPasteboardHolderView updateUIWithPasteObject:messageContent];
}


- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
