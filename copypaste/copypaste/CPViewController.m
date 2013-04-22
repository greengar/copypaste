//
//  CPViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "GMGridViewLayoutStrategies.h"
#import "GSSParseQueryHelper.h"

#define kUserHolderWidth 102
#define kUserHolderHeight 128
#define kUserBackgroundWidth 102
#define kUserBackgroundHeight 128
#define kUserAvatarWidth 98
#define kUserAvatarHeight 98
#define kUserNameWidth 102
#define kUserNameHeight 20
#define kPasteWidth 102
#define kPasteHeight 48

#define kContentViewTag 777
#define kLabelViewTag 778
#define kPasteLabelViewTag 779

@interface CPViewController ()

@end

@implementation CPViewController
@synthesize myPasteboardHolderView = _displayView;
@synthesize stringLabel = _stringLabel;
@synthesize imageHolderView = _imageHolderView;
@synthesize settingButton = _settingButton;
@synthesize availableUsersGridView = _availableUsersGridView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The background of the whole screen
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    backgroundImageView.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:backgroundImageView];
    
    // The header "copypaste"
    UIImageView *headerImageView = [[UIImageView alloc] init];
    headerImageView.frame = CGRectMake(6, 6, 308, 52);
    headerImageView.image = [UIImage imageNamed:@"header.png"];
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
    
    // The "my pasteboard holder view"
    self.myPasteboardHolderView = [[UIView alloc] initWithFrame:CGRectMake(8, 6+52+6, 304, 200)];
    self.myPasteboardHolderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.myPasteboardHolderView];
    
    // The "my pasteboard background image view"
    self.myPasteboardBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 304, 200)];
    self.myPasteboardBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.myPasteboardBackgroundImageView.image = [[UIImage imageNamed:@"pasteboard.png"] stretchableImageWithLeftCapWidth:30
                                                                                                             topCapHeight:30];
    [self.myPasteboardHolderView addSubview:self.myPasteboardBackgroundImageView];
    
    // The "pasteboard" header view
    UILabel *pasteboardHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 304, 30)];
    pasteboardHeaderLabel.text = @"pasteboard";
    pasteboardHeaderLabel.backgroundColor = [UIColor clearColor];
    pasteboardHeaderLabel.textColor = OPAQUE_HEXCOLOR(0xc8afa7);
    pasteboardHeaderLabel.textAlignment = UITextAlignmentCenter;
    pasteboardHeaderLabel.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
    [self.myPasteboardHolderView addSubview:pasteboardHeaderLabel];
    
    // The "pasteboard" string content
    self.stringLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 42, 304, 158)];
    self.stringLabel.backgroundColor = [UIColor clearColor];
    self.stringLabel.textColor = [UIColor whiteColor];
    self.stringLabel.textAlignment = UITextAlignmentCenter;
    self.stringLabel.editable = NO;
    self.stringLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    self.stringLabel.hidden = YES;
    [self.myPasteboardHolderView addSubview:self.stringLabel];
    
    self.imageHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 304, 158)];
    self.imageHolderView.backgroundColor = [UIColor clearColor];
    self.imageHolderView.hidden = YES;
    [self.myPasteboardHolderView addSubview:self.imageHolderView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:kNotificationApplicationDidBecomeActive
                                               object:nil];
    
    self.availableUsersGridView = [[GMGridView alloc] initWithFrame:CGRectMake(6, 270, 308, 148)];
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
    [self updateUI];
}

- (void)updateUI {
    [self hideOldCopiedContent];
    
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    if ([itemToPaste isKindOfClass:[NSString class]]) {
        self.stringLabel.hidden = NO;
        [self.stringLabel setText:((NSString *) itemToPaste)];
    } else if ([itemToPaste isKindOfClass:[UIImage class]]) {
        self.imageHolderView.hidden = NO;
        [self.imageHolderView setImage:((UIImage *) itemToPaste)];
    }
    
    [self.availableUsersGridView reloadData];
}

- (void)settingButtonTapped:(id)sender {
    [[GSSSession activeSession] logOut];
    [self viewDidAppear:YES];
}

- (void)hideOldCopiedContent {
    self.stringLabel.hidden = YES;
    self.imageHolderView.hidden = YES;
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

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [[[DataManager sharedManager] nearByUserList] count];
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
        
        EGOImageView *contentView = [[EGOImageView alloc] initWithFrame:CGRectMake(4,
                                                                                   4,
                                                                                   kUserAvatarWidth,
                                                                                   kUserAvatarHeight)];
        contentView.tag = kContentViewTag;
        contentView.image = [UIImage imageNamed:@"pasteboard.png"];
        contentView.delegate = self;
        [cell addSubview:contentView];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          kUserNameWidth,
                                                                          kUserNameHeight)];
        contentLabel.textAlignment = UITextAlignmentCenter;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
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
    
    if ([[[DataManager sharedManager] nearByUserList] count] == 0) {
        UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
        [contentLabel setText:@"No available user"];
        
    } else {
        CPUser * user = [[[DataManager sharedManager] nearByUserList] objectAtIndex:index];
        EGOImageView *contentView = (EGOImageView *) [cell viewWithTag:kContentViewTag];
        UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
        
        if (user != nil) {
            [contentView setImageURL:[NSURL URLWithString:user.avatarURLString]];
            [contentView setDelegate:self];
        }
        
        [contentLabel setText:user.username];
    }
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView_ didTapOnItemAtIndex:(NSInteger)position {
    
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
