//
//  RoomDataViewController.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/12/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "RoomDataViewController.h"
#import "GSSession.h"

@interface RoomDataViewController ()
@property (nonatomic, strong) UITextView *dataTextView;
@end

@implementation RoomDataViewController
@synthesize room = _room;
@synthesize dataTextView = _dataTextView;

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
	self.dataTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.dataTextView];
    
    [self showData];
}

- (void)showData {
    [self.dataTextView setText:[self.room.data description]];
}

- (void)dataDidChanged:(GSRoom *)room {
    [self showData];
}

- (void)dealloc {
    [[GSSession activeSession] unregisterRoomDataChanged:self.room];
    [self.room setDelegate:nil];
}

@end
