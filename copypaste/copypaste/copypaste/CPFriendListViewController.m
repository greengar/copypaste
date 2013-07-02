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
#import "MKNumberBadgeView.h"
#import "ODRefreshControl.h"

#define kNavigationBarHeight 66
#define kAvatarImageTag 777
#define kBadgeTag 778
#define kSortButtonWidth (self.view.frame.size.width-kNavigationBarHeight)/2
#define kSortButtonHeight kNavigationBarHeight
#define kSearchBarHeight 44

typedef enum {
    SortTypeLocation = 0,
    SortTypeName
} SortType;

@interface CPFriendListViewController ()
@property (nonatomic, strong) UIButton *sortLocationButton;
@property (nonatomic, strong) UIButton *sortNameButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *availableUsers;
@property (nonatomic, strong) NSMutableArray *sortedByNameUsers;
@property (nonatomic) SortType sortType;
@end

@implementation CPFriendListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = kCPBackgroundColor;
        
        CPNavigationView *navigationView = [[CPNavigationView alloc] initWithFrame:CGRectMake(0,
                                                                                              0,
                                                                                              self.view.frame.size.width,
                                                                                              kNavigationBarHeight)
                                                                           hasBack:YES
                                                                           hasDone:NO];
        navigationView.delegate = self;
        [self.view addSubview:navigationView];
        
        self.availableUsers = [NSMutableArray arrayWithArray:[[DataManager sharedManager] availableUsers]];
        self.sortedByNameUsers = [NSMutableArray arrayWithArray:[[DataManager sharedManager] sortedAvailableUsersByName]];
        self.sortType = SortTypeLocation;
        
        self.sortLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sortLocationButton setFrame:CGRectMake(kNavigationBarHeight,
                                                     0,
                                                     kSortButtonWidth,
                                                     kSortButtonHeight)];
        [self.sortLocationButton setTitle:@"location" forState:UIControlStateNormal];
        [self.sortLocationButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.sortLocationButton.titleLabel setShadowColor:[UIColor blackColor]];
        [self.sortLocationButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.sortLocationButton setBackgroundColor:kCPPasteTextColor];
        [self.sortLocationButton addTarget:self
                               action:@selector(sortLocationButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.sortLocationButton];
        
        self.sortNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sortNameButton setFrame:CGRectMake(self.view.frame.size.width-kSortButtonWidth,
                                                 0,
                                                 kSortButtonWidth,
                                                 kSortButtonHeight)];
        [self.sortNameButton setTitle:@"name" forState:UIControlStateNormal];
        [self.sortNameButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.sortNameButton.titleLabel setShadowColor:[UIColor blackColor]];
        [self.sortNameButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.sortNameButton setBackgroundColor:kCPBackgroundColor];
        [self.sortNameButton addTarget:self
                                action:@selector(sortNameButtonTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.sortNameButton];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                       kNavigationBarHeight,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height-kNavigationBarHeight)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               self.view.frame.size.width,
                                                                               kSearchBarHeight)];
        [GSUtils removeSearchBarBackground:self.searchBar];
        [GSUtils changeSearchBarReturnKeyToReturn:self.searchBar];
        [self.searchBar setDelegate:self];
        self.tableView.tableHeaderView = self.searchBar;
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self
                           action:@selector(dropViewDidBeginRefreshing:)
                 forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)backButtonTapped {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.availableUsers removeAllObjects];
    if ([searchText length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName CONTAINS %@", searchText];
        NSArray *filteredArray;
        if (self.sortType == SortTypeLocation) {
            filteredArray = [[[DataManager sharedManager] availableUsers] filteredArrayUsingPredicate:predicate];
        } else {
            filteredArray = [self.sortedByNameUsers filteredArrayUsingPredicate:predicate];
        }
        [self.availableUsers addObjectsFromArray:filteredArray];
    } else {
        if (self.sortType == SortTypeLocation) {
            [self.availableUsers addObjectsFromArray:[[DataManager sharedManager] availableUsers]];
        } else {
            [self.availableUsers addObjectsFromArray:self.sortedByNameUsers];
        }
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl {
    [[GSSession activeSession] getNearbyUserWithBlock:^(NSArray *listOfUsers, NSError *error) {
        if ([listOfUsers count] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No nearby user"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [refreshControl endRefreshing];
            [self.tableView reloadData];
            
        } else {
            [[DataManager sharedManager] updateNearbyUsers:listOfUsers];
            [self.tableView reloadData];
            
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
                                                    [refreshControl endRefreshing];
                                                    for (GSObject *object in objects) {
                                                        user.numOfCopyFromMe = [[object objectForKey:@"num_of_msg"] intValue];
                                                    }
                                                    [self.tableView reloadData];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateUserList object:nil];
                                                }];
            }
        }
    }];
}

- (void)sortLocationButtonTapped:(id)sender {
    self.sortType = SortTypeLocation;
    self.sortLocationButton.backgroundColor = kCPPasteTextColor;
    self.sortNameButton.backgroundColor = kCPBackgroundColor;
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
}

- (void)sortNameButtonTapped:(id)sender {
    self.sortType = SortTypeName;
    self.sortLocationButton.backgroundColor = kCPBackgroundColor;
    self.sortNameButton.backgroundColor = kCPPasteTextColor;
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
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
    return [self.availableUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tableViewCellIdentifier = @"FriendListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableViewCellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"default_avatar.png"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = DEFAULT_FONT_SIZE(15.0f);
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = DEFAULT_FONT_SIZE(11.0f);
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        EGOImageView *avatarImage = [[EGOImageView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   cell.frame.size.height-1,
                                                                                   cell.frame.size.height-1)];
        avatarImage.delegate = self;
        avatarImage.tag = kAvatarImageTag;
        avatarImage.contentMode = UIViewContentModeScaleAspectFill;
        avatarImage.clipsToBounds = YES;
        [cell addSubview:avatarImage];
        
        MKNumberBadgeView *badgeView = [[MKNumberBadgeView alloc] init];
        [badgeView setFrame:CGRectMake(cell.frame.size.width-cell.frame.size.height-1,
                                       0,
                                       cell.frame.size.height-1,
                                       cell.frame.size.height-1)];
        badgeView.tag = kBadgeTag;
        [cell addSubview:badgeView];
    }
    
    CPUser *user = [self.availableUsers objectAtIndex:[indexPath row]];
    
    if (user.isAvatarCached) {
        [((EGOImageView *) [cell viewWithTag:kAvatarImageTag]) setImage:user.avatarImage];
    } else {
        [((EGOImageView *) [cell viewWithTag:kAvatarImageTag]) setImageURL:[NSURL URLWithString:user.avatarURLString]];
    }
    cell.contentView.backgroundColor = ([indexPath row] % 2) ? kCPLightOrangeColor : kCPPasteTextColor;
    cell.textLabel.text = [user displayName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@", [user distanceStringToUser:[GSSession currentUser]]];
    [((MKNumberBadgeView *) [cell viewWithTag:kBadgeTag]) setValue:user.numOfUnreadMessage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CPUser *user = [self.availableUsers objectAtIndex:[indexPath row]];
    CPUser *actualUser = [[DataManager sharedManager] userById:user.uid];
    CPFullProfileViewController *profileViewController = [[CPFullProfileViewController alloc] init];
    profileViewController.profileUser = actualUser;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}

@end
