//
//  CPViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Smartboard/Smartboard.h>
#import <Smartboard/OHAttributedLabel.h>
#import <Smartboard/GSTheme.h>
#import <Smartboard/GSSVProgressHUD.h>
#import <Smartboard/NSData+GSBase64.h>

#define kContentViewTag 777
#define kLabelViewTag 778

#define kOffset 6
#define kHeaderViewHeight 52
#define kPasteboardMinimumHeight (IS_IPHONE5 ? 328 : 240)
#define kUserViewHeight 155
#define kUserViewWidth 91

typedef enum {
    ErrorNoInternetConnection = 0,
    ErrorCannotConnectServer,
    ErrorNoAvailableUsers
} ErrorType;

@interface CPViewController ()
@property (nonatomic) ErrorType currentErrorType;
@end

@implementation CPViewController

@synthesize myPasteboardHolderView = _myPasteboardHolderView;
@synthesize userProfilePopoverController = _userProfilePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kCPBackgroundColor;
    
    OHAttributedLabel *logo = [GSTheme logoWithSize:32];
    CGRect frame = logo.frame;
    frame.origin.y = kOffset;
    logo.frame = frame;
    logo.centerVertically = YES;
    [self.view addSubview:logo];
    
    // Help button
    UIImage *helpImage = [UIImage imageNamed:@"help.fw.png"];
    self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.helpButton.frame = CGRectMake(self.view.frame.size.width - helpImage.size.width, 0, helpImage.size.width, helpImage.size.height);
    [self.helpButton setBackgroundImage:helpImage forState:UIControlStateNormal];
    [self.helpButton addTarget:self action:@selector(helpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.helpButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.helpButton.frame.origin.x-1, 0, 1, helpImage.size.height)];
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:line];
    
    // The avatar image view of the logged in user
    self.avatarImageButton = [[EGOImageButton alloc] initWithFrame:CGRectMake(0, 0, helpImage.size.width, helpImage.size.height)];
    self.avatarImageButton.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarImageButton setBackgroundImage:[UIImage imageNamed:@"default_avatar.png"] forState:UIControlStateNormal];
    [self.avatarImageButton addTarget:self action:@selector(avatarImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.avatarImageButton];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(self.avatarImageButton.frame.size.width, 0, 1, self.avatarImageButton.frame.size.height)];
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:line];
    
    // The "my pasteboard holder view"
    const float y = logo.frame.origin.y * 2 + logo.frame.size.height;
    self.myPasteboardHolderView = [[CPPasteboardView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y - kUserViewHeight)];
    self.myPasteboardHolderView.delegate = self;
    [self.view addSubview:self.myPasteboardHolderView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPasteboardView)
                                                 name:kNotificationApplicationDidBecomeActive
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getFileURL:)
                                                 name:kNotificationOpenFileURL
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTop3UsersView)
                                                 name:kNotificationUpdateUserList
                                               object:nil];
    
    self.userViews = [NSMutableArray arrayWithCapacity:3];
    
    // Top 3 users display view
    for (int i = 0; i < 3; i++) {
        CPUserView *userView = [[CPUserView alloc] initWithFrame:CGRectMake(92 * i,
                                                                            self.view.frame.size.height-kUserViewHeight,
                                                                            kUserViewWidth,
                                                                            kUserViewHeight)];
        userView.delegate = self;
        userView.isLight = (i % 2) ? NO : YES;
        [self.view addSubview:userView];
        [self.userViews addObject:userView];
    }
    
    // 'more users' button, tap to show the friend list
    float x = 92*3;
    self.moreUsersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kUserViewHeight, self.view.frame.size.width-x)]; // Just init
    self.moreUsersButton.center = CGPointMake(x+(self.view.frame.size.width-x)/2,
                                              self.view.frame.size.height-kUserViewHeight/2); // Correct frame
    self.moreUsersButton.transform = CGAffineTransformMakeRotation(-M_PI/2); // Rotate left
    self.moreUsersButton.backgroundColor = kCPPasteTextColor;
    self.moreUsersButton.titleLabel.shadowColor = [UIColor blackColor];
    self.moreUsersButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [self.moreUsersButton addTarget:self
                             action:@selector(moreUsersButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreUsersButton];
    
    // The loading indicator on top of the more users button
    self.moreUsersLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.moreUsersLoadingIndicator.center = CGPointMake((self.view.frame.size.width+x)/2, self.view.frame.size.height-kUserViewHeight/2);
    [self.moreUsersLoadingIndicator startAnimating];
    [self.view addSubview:self.moreUsersLoadingIndicator];
    
    // The 'No Internet Connection' indicator view
    self.noInternetConnectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noInternetConnectionButton.frame = CGRectMake(0,
                                                       self.view.frame.size.height-kUserViewHeight,
                                                       self.view.frame.size.width,
                                                       kUserViewHeight);
    self.noInternetConnectionButton.backgroundColor = kCPPasteTextColor;
    [self.noInternetConnectionButton addTarget:self
                                        action:@selector(reloadButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
    self.noInternetConnectionButton.titleLabel.font = DEFAULT_FONT_SIZE(15.0f);
    self.noInternetConnectionButton.titleLabel.textColor = [UIColor whiteColor];
    self.noInternetConnectionButton.hidden = YES;
    [self.noInternetConnectionButton setTitle:@"No Internet Connection! Reload?" forState:UIControlStateNormal];
    [self.view addSubview:self.noInternetConnectionButton];
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[DataManager sharedManager] hasInternetConnection]) {
            if ([GSSession isAuthenticated]) {
                [self reloadCurrentUserView];
                [[GSSession activeSession] updateUserInfoFromSmartboardAPIWithBlock:^(BOOL succeed, NSError *error) {
                    if (error) {
                        [self showErrorType:ErrorCannotConnectServer];
                    } else {
                        [self finishAuthentication];
                    }
                }];
            } else {
                [[GSSession activeSession] authenticateSmartboardAPIFromViewController:self
                                                                              delegate:self];
            }
        } else {
            [self showErrorType:ErrorNoInternetConnection];
        }
    });
}

- (void)avatarImageButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                        message:[NSString stringWithFormat:@"You have logged in as %@. Do you want to log out?", [[GSSession activeSession] currentUserName]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Log Out", nil];
    [alertView show];
}

- (void)helpButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Copy to set clipboard content"
                                                        message:@"In any app, use Cut or Copy to set the content of your clipboard."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)moreUsersButtonTapped:(id)sender {
    if (![[DataManager sharedManager] checkedVersion_1_0]) {
        [self.myPasteboardHolderView hideInstruction];
    }
    
    if ([[[DataManager sharedManager] availableUsers] count] < 3) { // No more users
        return;
    }
    
    CPFriendListViewController *friendListViewController = [[CPFriendListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)finishAuthentication {
    [[GSSession activeSession] registerMessageReceiver:self];
    [self reloadCurrentUserView];
    [self reloadPasteboardView];
    [self reloadAllAvailableUsers];
}

- (void)didLoginSucceeded {
    [self dismissModalViewControllerAnimated:YES];
    [self finishAuthentication];
}

- (void)didLoginFailed:(NSError *)error {
    [self showErrorType:ErrorNoInternetConnection];
}

- (void)finishInstruction {
    [self reloadPasteboardView];
}

- (void)reloadPasteboardView {
    if (![[DataManager sharedManager] checkedVersion_1_0]) {
        [self.myPasteboardHolderView showInstruction];
    }
    
    [self hideOldCopiedContent];
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    [self.myPasteboardHolderView updateUIWithPasteObject:itemToPaste];
}

- (void)hideOldCopiedContent {
    self.myPasteboardHolderView.pasteboardTextView.hidden = YES;
    self.myPasteboardHolderView.pasteboardImageHolderView.hidden = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[GSSession activeSession] logOutWithBlock:^(BOOL succeed, NSError *error) {
            [self.avatarImageButton setImage:nil forState:UIControlStateNormal];
            [[[DataManager sharedManager] availableUsers] removeAllObjects];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You have logged out"
                                                                message:@"Please log in in order to use copypaste"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [[GSSession activeSession] authenticateSmartboardAPIFromViewController:self
                                                                          delegate:self];

        }];
    }
}

- (void)didTapPasteUser:(CPUser *)user {
    if (![[DataManager sharedManager] checkedVersion_1_0]) {
        [self.myPasteboardHolderView hideInstruction];
    }
    
    if (![[DataManager sharedManager] hasInternetConnection]) {
        [self showErrorType:ErrorNoInternetConnection];
    } else {
        [GSSVProgressHUD showWithStatus:@"Pasting..."];
        [[DataManager sharedManager] pasteToUser:user
                                           block:^(BOOL succeed, NSError *error) {
                                               [GSSVProgressHUD dismiss];
                                               if (succeed) {
                                                   [self reloadTop3UsersView];
                                               } else {
                                                   [self showErrorType:ErrorCannotConnectServer];
                                               }
                                           }];
    }
}

- (void)didTapAvatarUserView:(CPUserView *)userView {
    if (![[DataManager sharedManager] checkedVersion_1_0]) {
        [self.myPasteboardHolderView hideInstruction];
    }
    
    CPUser *user = userView.user;
    
    CPShortProfileViewController *profileViewController = [[CPShortProfileViewController alloc] init];
    profileViewController.profileUser = user;
    profileViewController.view.frame = CGRectMake(0, 0, 320, 200);
    
    self.userProfilePopoverController = [[WEPopoverController alloc] initWithContentViewController:profileViewController];
    [self.userProfilePopoverController setPopoverContentSize:CGSizeMake(320, 200)];
    [self.userProfilePopoverController setDelegate:self];
    
    [self.userProfilePopoverController presentPopoverFromRect:userView.frame
                                                       inView:self.view
                                     permittedArrowDirections:UIPopoverArrowDirectionDown
                                                     animated:NO];
}

- (void)reloadButtonTapped:(id)sender {
    if (![[DataManager sharedManager] hasInternetConnection]) {
        [self showErrorType:ErrorNoInternetConnection];
    } else {
        switch (self.currentErrorType) {
            case ErrorNoInternetConnection:
            case ErrorCannotConnectServer:
                [self reloadCurrentUserView];
                [self reloadPasteboardView];
                [self reloadAllAvailableUsers];
                break;
            case ErrorNoAvailableUsers:
                [self reloadAllAvailableUsers];
                break;
            default:
                break;
        }
        
        for (CPUserView *userView in self.userViews) {
            [userView.loadingIndicator startAnimating];
        }
        [self.moreUsersLoadingIndicator startAnimating];
    }
}


- (void)reloadCurrentUserView {
    if ([GSSession isAuthenticated]) {
        CPUser *currentUser = (CPUser *) [[GSSession activeSession] currentUser];
        if ([currentUser isAvatarCached]) {
            [self.avatarImageButton setImage:currentUser.avatarImage forState:UIControlStateNormal];
        } else if ([currentUser avatarURLString]) {
            [self.avatarImageButton setImageURL:[NSURL URLWithString:currentUser.avatarURLString]];
            [self.avatarImageButton setDelegate:self];
        } else {
            [self.avatarImageButton setImage:nil forState:UIControlStateNormal];
        }
    } else {
        [self.avatarImageButton setImage:nil forState:UIControlStateNormal];
    }
}

- (void)reloadTop3UsersView {
    NSArray *top3Users = [[DataManager sharedManager] getTop3Users];
    
    for (int i = 0; i < [top3Users count]; i++) {
        CPUser *user = [top3Users objectAtIndex:i];
        [(CPUserView *)self.userViews[i] setUser:user];
        [(CPUserView *)self.userViews[i] setNeedsDisplay];
    }
    
    if ([[[DataManager sharedManager] availableUsers] count] > 3) {
        [self.moreUsersButton setTitle:@"more users" forState:UIControlStateNormal];
        [self.moreUsersLoadingIndicator stopAnimating];
    } else {
        [self.moreUsersButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)reloadAllAvailableUsers {
    [[GSSession activeSession] getNearbyUserWithBlock:^(NSArray *listOfUsers, NSError *error) {
        if (error) {
            [self showErrorType:ErrorCannotConnectServer];
            
        } else if ([listOfUsers count] == 0) {
            [self showErrorType:ErrorNoAvailableUsers];
            
        } else {
            self.noInternetConnectionButton.hidden = YES;
            [[DataManager sharedManager] updateNearbyUsers:listOfUsers];
            [self reloadTop3UsersView];
            
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
                                                        user.numOfPasteToMe = [[object objectForKey:@"num_of_msg"] intValue];
                                                        [self reloadTop3UsersView];
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
                                                        user.numOfCopyFromMe = [[object objectForKey:@"num_of_msg"] intValue];
                                                        [self reloadTop3UsersView];
                                                    }
                                                }];
            }
        }
    }];
}

- (void)showMessage:(NSObject *)messageContent info:(NSDictionary *)dictInfo {
    NSString *senderUID = [dictInfo objectForKey:@"sender"];
    NSString *messageTime = [dictInfo objectForKey:@"time"];
    NSString *messageUid = [dictInfo objectForKey:@"uid"];
    CPUser *sender = [[DataManager sharedManager] userById:senderUID];
    
    if (sender == nil) { // The sender is not a nearby user
        sender = [[CPUser alloc] init];
        sender.uid = senderUID;
        sender.fullname = [dictInfo objectForKey:@"sender_name"];
        sender.username = [dictInfo objectForKey:@"sender_name"];
        sender.avatarURLString = [dictInfo objectForKey:@"sender_avatar"];
        sender.location = [[PFGeoPoint alloc] init];
        sender.location.longitude = [[dictInfo objectForKey:@"sender_long"] doubleValue];
        sender.location.latitude = [[dictInfo objectForKey:@"sender_lat"] doubleValue];
    }
    
    CPMessage *newMessage = [[CPMessage alloc] init];
    [newMessage setUid:messageUid];
    [newMessage setSender:sender];
    [newMessage setContent:messageContent];
    [newMessage setMessageTime:messageTime];
    [newMessage setCreatedDateInterval:[[GSUtils dateFromString:messageTime] timeIntervalSince1970]];
    DLog(@"Receive message: %@", [newMessage description]);
    
    if ([[DataManager sharedManager] updateMessageList:newMessage]) {
        // Get more message from the sender
        sender.numOfPasteToMe++;
        sender.numOfUnreadMessage++;
        
        [[GSSession activeSession] removeMessageFromSender:sender atTime:messageTime];
        
        CPMessageView *messageView = [[CPMessageView alloc] initWithFrame:CGRectMake(0,
                                                                                     0,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height)
                                                                  message:newMessage
                                                               controller:self];
        [messageView setDelegate:self];
        [messageView showMeOnView:self.view];
    }
}

- (void)didReceiveMessage:(NSDictionary *)dictInfo {
    NSString *receiverId = [dictInfo objectForKey:@"receiver"];
    if (![receiverId isEqualToString:[GSSession currentUser].uid]) {
        // It's not for me, so just ignore it
        return;
    }
    
    [GSSVProgressHUD showWithStatus:@"Receiving..."];
    NSString *messageType = [dictInfo objectForKey:@"type"];
    if ([messageType isEqualToString:@"string"]) {
        NSObject *messageContent = [dictInfo objectForKey:@"content"];
        [self showMessage:messageContent info:dictInfo];
        [GSSVProgressHUD dismiss];
        
    } else if ([messageType isEqualToString:@"image"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_current_queue(), ^{
                NSObject *messageContent;
                NSObject *messageRawContent = [dictInfo objectForKey:@"content"];
                if ([messageRawContent isKindOfClass:[NSArray class]]) {
                    NSMutableString *messageString = [NSMutableString new];
                    for (int i = 0; i < [((NSArray *) messageRawContent) count]; i++) {
                        [messageString appendString:[((NSArray *) messageRawContent) objectAtIndex:i]];
                    }
                    NSData *imageData = [NSData gsDataFromBase64String:messageString];
                    DLog(@"Receive image Size: %fMB", (float)[imageData length]/(float)(1024*1024));
                    messageContent = (NSObject *)[UIImage imageWithData:imageData];
                    
                } else {
                    NSData *imageData = [NSData gsDataFromBase64String:((NSString *)messageRawContent)];
                    DLog(@"Receive image Size: %fMB", (float)[imageData length]/(float)(1024*1024));
                    messageContent = [UIImage imageWithData:imageData];
                }
                [self showMessage:messageContent info:dictInfo];
                [GSSVProgressHUD dismiss];
            });
        });
    }
}

- (void)showErrorType:(ErrorType)errorType {
    self.currentErrorType = errorType;
    NSString *errorString = @"Unknown Error! Reload?";
    if (errorType == ErrorNoInternetConnection) {
        errorString = @"No Intenet connection! Reload?";
    } else if (errorType == ErrorNoAvailableUsers) {
        errorString = @"Can not load available users! Reload?";
    } else if (errorType == ErrorCannotConnectServer) {
        errorString = @"Can not connect server! Reload?";
    }
    self.noInternetConnectionButton.hidden = NO;
    [self.noInternetConnectionButton setTitle:errorString forState:UIControlStateNormal];
    
    for (CPUserView *userView in self.userViews) {
        [userView.loadingIndicator stopAnimating];
    }
    [self.moreUsersLoadingIndicator stopAnimating];
}

- (void)getFileURL:(NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey:@"content"];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"public.jpg"];
    [self reloadPasteboardView];
}

- (void)copyMessage:(CPMessage *)message {
    [self reloadPasteboardView];
}

- (void)discardMessage:(CPMessage *)message {
    [self reloadPasteboardView];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)wepopoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    [self reloadPasteboardView];
}

- (BOOL)wepopoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    [self reloadPasteboardView];
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
