//
//  CPViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPViewController.h"

@interface CPViewController ()

@end

@implementation CPViewController
@synthesize  displayView = _displayView;
@synthesize stringLabel = _stringLabel;
@synthesize imageHolderView = _imageHolderView;

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
    [self.displayView addSubview:self.stringLabel];
    
    self.imageHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.imageHolderView.backgroundColor = [UIColor clearColor];
    self.imageHolderView.hidden = YES;
    [self.displayView addSubview:self.imageHolderView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:kNotificationApplicationDidBecomeActive
                                               object:nil];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
