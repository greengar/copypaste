//
//  CPFriendListViewController.m
//  copypaste
//
//  Created by Hector Zhao on 5/1/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPFriendListViewController.h"
#import "DataManager.h"
#import "CPFullProfileViewController.h"

#define kAvatarImageTag 777

@interface CPFriendListViewController ()

@end

@implementation CPFriendListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = kCPBackgroundColor;
        
        UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
        topButton.frame = CGRectMake(0, 0, 320, 66);
        topButton.backgroundColor = [UIColor clearColor];
        [topButton addTarget:self action:@selector(topButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:topButton];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 66, 320, 394)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
    }
    return self;
}

- (void)topButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[DataManager sharedManager] availableUsers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tableViewCellIdentifier = @"FriendListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableViewCellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"help.fw.png"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = DEFAULT_FONT_SIZE(15.0f);
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = DEFAULT_FONT_SIZE(11.0f);
        
        EGOImageView *avatarImage = [[EGOImageView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   cell.frame.size.height-1,
                                                                                   cell.frame.size.height-1)];
        avatarImage.delegate = self;
        avatarImage.tag = kAvatarImageTag;
        avatarImage.contentMode = UIViewContentModeScaleAspectFill;
        avatarImage.clipsToBounds = YES;
        [cell addSubview:avatarImage];        
    }
    
    CPUser *user = [[[DataManager sharedManager] availableUsers] objectAtIndex:[indexPath row]];
    
    if (user.isAvatarCached) {
        [((EGOImageView *) [cell viewWithTag:kAvatarImageTag]) setImage:user.avatarImage];
    } else {
        [((EGOImageView *) [cell viewWithTag:kAvatarImageTag]) setImageURL:[NSURL URLWithString:user.avatarURLString]];
    }
    cell.contentView.backgroundColor = ([indexPath row] % 2) ? kCPLightOrangeColor : kCPPasteTextColor;
    cell.textLabel.text = [user displayName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@", [user distanceStringToUser:[GSSession currentUser]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    CPUser *user = [[[DataManager sharedManager] availableUsers] objectAtIndex:[indexPath row]];
//    
//    CPFullProfileViewController *profileViewController = [[CPFullProfileViewController alloc] init];
//    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}

@end
