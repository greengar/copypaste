//
//  RoomListViewController.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/12/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "RoomListViewController.h"
#import "RoomDataViewController.h"
#import "GSRoom.h"
#import "GSSession.h"

@interface RoomListViewController ()

@end

@implementation RoomListViewController
@synthesize rooms = _rooms;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    GSRoom *room = [self.rooms objectAtIndex:[indexPath row]];
    [cell.textLabel setText:room.name];
    [cell.detailTextLabel setText:room.ownerId];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GSRoom *room = [self.rooms objectAtIndex:[indexPath row]];
    [[GSSession activeSession] registerRoomDataChanged:room withBlock:^(BOOL succeed, NSError *error) {
        RoomDataViewController *controller = [[RoomDataViewController alloc] init];
        [controller setRoom:room];
        [controller setTitle:room.name];
        [room setDelegate:controller];
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

@end
