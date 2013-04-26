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
#import "GSParseQueryHelper.h"
#import "NSData+Base64.h"

#define kUserHolderWidth 102
#define kUserHolderHeight 140
#define kUserAvatarWidth 76
#define kUserAvatarHeight 76
#define kUsernameOffset 3
#define kUsernameHeight 23

#define kContentViewTag 777
#define kLabelViewTag 778

#define kOffset 6
#define kHeaderViewHeight 52
#define kPasteboardMinimumHeight (IS_IPHONE5 ? 338 : 250)

@interface CPViewController ()

@end

@implementation CPViewController
@synthesize myPasteboardHolderView = _myPasteboardHolderView;
@synthesize userProfilePopoverController = _userProfilePopoverController;
@synthesize settingButton = _settingButton;
@synthesize availableUsersGridView = _availableUsersGridView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The background of the whole screen
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (IS_IPHONE5) {
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
    //self.myPasteboardHolderView.clipsToBounds = YES; // pasteboardHeaderImageView is positioned slightly beyond bounds (can change this)
    [self.view addSubview:self.myPasteboardHolderView];
                
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
    
    if ([GSSession isAuthenticated]) {
        [self finishAuthentication];
    } else {
        [[GSSession activeSession] authenticateSmartboardAPIFromViewController:self
                                                                      delegate:self];
    }
}

- (void)finishAuthentication {
    [[GSSession activeSession] getNearbyUserWithBlock:^(NSArray *listOfUsers, NSError *error) {
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
            
            for (CPUser *user in [[DataManager sharedManager] availableUsers]) {
                
                // To get number of paste to me
                NSMutableArray *queryCondition = [NSMutableArray new];
                [queryCondition addObject:@"sender_id"];
                [queryCondition addObject:user.uid];
                [queryCondition addObject:@"receiver_id"];
                [queryCondition addObject:[[[GSSession activeSession] currentUser] uid]];
                
                [[GSSession activeSession] queryClass:@"CopyAndPaste"
                                                where:queryCondition
                                                block:^(NSArray *objects, NSError *error) {
                    for (GSObject *object in objects) {
                        DLog(@"%@ has pasted %d messages to me", [object objectForKey:@"sender_id"], [[object objectForKey:@"num_of_msg"] intValue]);
                        user.numOfPasteToMe = [[object objectForKey:@"num_of_msg"] intValue];
                    }
                }];
                
                // To get number of copy from me
                [queryCondition removeAllObjects];
                [queryCondition addObject:@"receiver_id"];
                [queryCondition addObject:user.uid];
                [queryCondition addObject:@"sender_id"];
                [queryCondition addObject:[[[GSSession activeSession] currentUser] uid]];
                
                [[GSSession activeSession] queryClass:@"CopyAndPaste"
                                                where:queryCondition
                                                block:^(NSArray *objects, NSError *error) {
                    for (GSObject *object in objects) {
                        DLog(@"I have copied %d messages to %@", [[object objectForKey:@"num_of_msg"] intValue], [object objectForKey:@"receiver_id"]);
                        user.numOfCopyFromMe = [[object objectForKey:@"num_of_msg"] intValue];
                    }
                }];
            }
        }
    }];
    [[GSSession activeSession] addObserver:self];
    [self updateUI];
}

- (void)didLoginSucceeded {
    [self dismissModalViewControllerAnimated:YES];
    [self finishAuthentication];
}

- (void)didLoginFailed:(NSError *)error {
    // I think we have nothing to do now
}

- (void)updateUI {
    [self hideOldCopiedContent];
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    [self.myPasteboardHolderView updateUIWithPasteObject:itemToPaste];
        
    if ([GSSession isAuthenticated]) {
        CPUser *currentUser = (CPUser *) [[GSSession activeSession] currentUser];
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
                                                        message:[NSString stringWithFormat:@"You have logged in as %@. Do you want to log out?", [[GSSession activeSession] currentUserName]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Log Out", nil];
    [alertView show];
}

- (void)hideOldCopiedContent {
    self.myPasteboardHolderView.pasteboardTextView.hidden = YES;
    self.myPasteboardHolderView.pasteboardImageHolderView.hidden = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[GSSession activeSession] logOut];
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

- (void)pasteToUserAtPosition:(NSInteger)position {
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    CPUser * user = [[[DataManager sharedManager] availableUsers] objectAtIndex:position];
    if (itemToPaste) {
        [[GSSession activeSession] sendMessage:itemToPaste toUser:user];
        user.numOfCopyFromMe++;
        
        NSMutableArray *sendCondition = [NSMutableArray new];
        [sendCondition addObject:@"sender_id"];
        [sendCondition addObject:[[[GSSession activeSession] currentUser] uid]];
        [sendCondition addObject:@"receiver_id"];
        [sendCondition addObject:[user uid]];
        
        NSMutableArray *valueToSet = [NSMutableArray new];
        [valueToSet addObject:@"num_of_msg"];
        [valueToSet addObject:[NSNumber numberWithInt:user.numOfCopyFromMe]];
        
        [[GSSession activeSession] updateClass:@"CopyAndPaste"
                                          with:valueToSet
                                         where:sendCondition
                                         block:^(NSError *error) {
                                             [self updateUI];
                                         }];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not paste"
                                                            message:[NSString stringWithFormat:@"Your clipboard is empty, please copy something to paste to %@!", user.fullname]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)pasteToUserWithButton:(UIButton *)button {
    [self pasteToUserAtPosition:button.tag];
}

- (void)showUserProfileAtPosition:(NSInteger)position {
    CPProfileViewController *profileViewController = [[CPProfileViewController alloc] init];
    profileViewController.profileUser = [[[DataManager sharedManager] availableUsers] objectAtIndex:position];
    profileViewController.view.frame = CGRectMake(0, 0, 320, 200);
    
    self.userProfilePopoverController = [[WEPopoverController alloc] initWithContentViewController:profileViewController];
    [self.userProfilePopoverController setPopoverContentSize:CGSizeMake(320, 200)];
    [self.userProfilePopoverController setDelegate:self];
    
    float popoverWidth = self.availableUsersGridView.frame.size.width;
    switch (position % 3) {
        case 0:
            popoverWidth = self.availableUsersGridView.frame.size.width/3;
            break;
        case 1:
            popoverWidth = self.availableUsersGridView.frame.size.width;
            break;
        case 2:
            popoverWidth = self.availableUsersGridView.frame.size.width*3/2;
            break;
        default:
            break;
    }
    CGRect popoverRect = CGRectMake(self.availableUsersGridView.frame.origin.x,
                                    self.availableUsersGridView.frame.origin.y+20,
                                    popoverWidth,
                                    self.availableUsersGridView.frame.size.height);
    [self.userProfilePopoverController presentPopoverFromRect:popoverRect
                                                       inView:self.view
                                     permittedArrowDirections:UIPopoverArrowDirectionDown
                                                     animated:NO];
}

- (void)showUserProfileWithButton:(UIButton *)button {
    [self showUserProfileAtPosition:button.tag];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView_ cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView_ dequeueReusableCellWithIdentifier:@"layerCell"];
    
    if(cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.clipsToBounds = YES;
        
        UIImage *personBackgroundImage = [UIImage imageNamed:@"person-background.fw.png"];
        UIButton *personBackgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      personBackgroundImage.size.width,
                                                                                      personBackgroundImage.size.height)];
        [personBackgroundButton setBackgroundColor:[UIColor clearColor]];
        [personBackgroundButton setImage:personBackgroundImage forState:UIControlStateNormal];
        [personBackgroundButton setTag:index];
        [personBackgroundButton addTarget:self action:@selector(showUserProfileWithButton:)
                         forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:personBackgroundButton];
        
        EGOImageView *contentView = [[EGOImageView alloc] initWithFrame:CGRectMake((personBackgroundImage.size.width-kUserAvatarWidth)/2,
                                                                                   (personBackgroundImage.size.width-kUserAvatarWidth)/2,
                                                                                   kUserAvatarWidth,
                                                                                   kUserAvatarHeight)];
        contentView.tag = kContentViewTag;
        contentView.image = [UIImage imageNamed:@"pasteboard.png"];
        contentView.contentMode = UIViewContentModeScaleAspectFill;
        contentView.clipsToBounds = YES;
        contentView.delegate = self;
        [cell addSubview:contentView];
        
        UIImage *pasteButtonImage = [UIImage imageNamed:@"pastebutton.png"];
        UIButton *pasteButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           kUserHolderHeight - pasteButtonImage.size.height,
                                                                           pasteButtonImage.size.width,
                                                                           pasteButtonImage.size.height)];
        pasteButton.backgroundColor = [UIColor clearColor];
        [pasteButton setImage:pasteButtonImage forState:UIControlStateNormal];
        pasteButton.tag = index; // tag is used by -pasteToUserWithButton: to identify the user position
        [pasteButton addTarget:self action:@selector(pasteToUserWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:pasteButton];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kUsernameOffset,
                                                                          kUserHolderHeight - pasteButtonImage.size.height,
                                                                          pasteButtonImage.size.width-2*kUsernameOffset,
                                                                          kUsernameHeight)];
        contentLabel.textAlignment = UITextAlignmentCenter;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.font = [UIFont fontWithName:@"Heiti SC" size:11.0f];
        contentLabel.tag = kLabelViewTag;
        [cell addSubview:contentLabel];
    }
    
    if ([[[DataManager sharedManager] availableUsers] count] == 0) {
        UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
        [contentLabel setText:@"No available user"];
        
    } else {
        CPUser * user = [[[DataManager sharedManager] availableUsers] objectAtIndex:index];
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

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    
}

- (void)didReceiveMessageFrom:(NSString *)userId
                      content:(NSObject *)messageContent
                         time:(NSString *)messageTime {
    CPUser *user = [[DataManager sharedManager] userById:userId];
    
    CPMessage *newMessage = [[CPMessage alloc] init];
    [newMessage setSender:user];
    [newMessage setMessageContent:messageContent];
    [newMessage setCreatedDateInterval:[[GSUtils dateFromString:messageTime] timeIntervalSince1970]];
    DLog(@"Receive message: %@", [newMessage description]);
    [[[DataManager sharedManager] receivedMessages] addObject:newMessage];
    
    // Get more message from the sender
    user.numOfPasteToMe++;
    
    // Remove the value from the Firebase server, because it's catched
    [[GSSession activeSession] removeMessageFromSender:user atTime:messageTime];
    
    CPMessageView *messageView = [[CPMessageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)];
    [messageView addMessageContent:newMessage];
    [messageView showMeOnView:self.view];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)wepopoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    [self updateUI];
}

- (BOOL)wepopoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    [self updateUI];
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
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
