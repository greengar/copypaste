//
//  CPViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GMGridViewLayoutStrategies.h"

#define kUserHolderWidth 60
#define kUserHolderHeight 80
#define kUserAvatarWidth 60
#define kUserAvatarHeight 60
#define kUserNameWidth 60
#define kUserNameHeight 20
#define kPasteWidth 60
#define kPasteHeight 20

#define kContentViewTag 777
#define kLabelViewTag 778
#define kPasteLabelViewTag 779

@interface CPViewController ()

@end

@implementation CPViewController
@synthesize  displayView = _displayView;
@synthesize stringLabel = _stringLabel;
@synthesize imageHolderView = _imageHolderView;
@synthesize availableUsersGridView = _availableUsersGridView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *pasteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    pasteTitleLabel.backgroundColor = [UIColor clearColor];
    pasteTitleLabel.textAlignment = UITextAlignmentCenter;
    pasteTitleLabel.text = @"You have copied: ";
    [self.view addSubview:pasteTitleLabel];
    
    self.displayView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
    self.displayView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.displayView];
    
    self.stringLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.stringLabel.backgroundColor = [UIColor clearColor];
    self.stringLabel.textAlignment = UITextAlignmentCenter;
    self.stringLabel.editable = NO;
    self.stringLabel.font = [UIFont systemFontOfSize:15.0f];
    self.stringLabel.hidden = YES;
    self.stringLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.stringLabel.layer.borderWidth = 1.0f;
    [self.displayView addSubview:self.stringLabel];
    
    self.imageHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.imageHolderView.backgroundColor = [UIColor clearColor];
    self.imageHolderView.hidden = YES;
    self.imageHolderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.imageHolderView.layer.borderWidth = 1.0f;
    [self.displayView addSubview:self.imageHolderView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:kNotificationApplicationDidBecomeActive
                                               object:nil];
    
    self.availableUsersGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 380, 320, 100)];
    self.availableUsersGridView.dataSource = self;
    self.availableUsersGridView.actionDelegate = self;
    self.availableUsersGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    [self.view addSubview:self.availableUsersGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
}

- (void)hideOldCopiedContent {
    self.stringLabel.hidden = YES;
    self.imageHolderView.hidden = YES;
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
        
        EGOImageView *contentView = [[EGOImageView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   kUserAvatarWidth,
                                                                                   kUserAvatarHeight)];
        contentView.layer.borderWidth = 1;
        contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        contentView.tag = kContentViewTag;
        contentView.delegate = self;
        [cell addSubview:contentView];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          kUserAvatarHeight - kUserNameHeight,
                                                                          kUserNameWidth,
                                                                          kUserNameHeight)];
        contentLabel.textAlignment = UITextAlignmentCenter;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.tag = kLabelViewTag;
        [cell addSubview:contentLabel];
        
        UILabel *pasteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        kUserHolderHeight - kPasteHeight,
                                                                        kPasteWidth,
                                                                        kPasteHeight)];
        pasteLabel.textAlignment = UITextAlignmentCenter;
        pasteLabel.backgroundColor = [UIColor orangeColor];
        pasteLabel.textColor = [UIColor whiteColor];
        pasteLabel.shadowColor = [UIColor grayColor];
        pasteLabel.shadowOffset = CGSizeMake(0, -1);
        pasteLabel.tag = kPasteLabelViewTag;
        pasteLabel.text = @"Paste";
        [cell addSubview:pasteLabel];
    }
    
    CPUser * user = [[[DataManager sharedManager] nearByUserList] objectAtIndex:index];
    EGOImageView *contentView = (EGOImageView *) [cell viewWithTag:kContentViewTag];
    UILabel *contentLabel = (UILabel *) [cell viewWithTag:kLabelViewTag];
    
    if (user != nil) {
        [contentView setImageURL:[NSURL URLWithString:user.avatarURLString]];
        [contentView setDelegate:self];
    }
    
    [contentLabel setText:user.username];
    
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
