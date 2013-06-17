//
//  HistoryView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryView.h"
#import "WBUtils.h"
#import "GSButton.h"

@interface HistoryView()
@property (nonatomic, strong) UITableView *historyTableView;
@end

@implementation HistoryView
@synthesize historyTableView = _historyTableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [historyLabel setBackgroundColor:[UIColor lightGrayColor]];
        [historyLabel setText:@"History"];
        [historyLabel setTextAlignment:NSTextAlignmentCenter];
        [historyLabel setTextColor:[UIColor whiteColor]];
        [historyLabel setShadowColor:[UIColor darkGrayColor]];
        [historyLabel setShadowOffset:CGSizeMake(0, -1)];
        [historyLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [self addSubview:historyLabel];
        
        GSButton *closeButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GrayButtonStyle];
        [closeButton setFrame:CGRectMake(frame.size.width-44, 0, 44, 44)];
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        self.historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44)];
        [self.historyTableView setDelegate:self];
        [self.historyTableView setDataSource:self];
        [self.historyTableView setShowsVerticalScrollIndicator:YES];
        [self.historyTableView setShowsHorizontalScrollIndicator:YES];
        [self addSubview:self.historyTableView];
        
        [[HistoryManager sharedManager] setDelegate:self];
    }
    return self;
}

- (void)closeMe {
    [self setHidden:YES];
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[HistoryManager sharedManager] historyPool] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    HistoryAction *action = [[[HistoryManager sharedManager] historyPool] objectAtIndex:[indexPath row]];
    cell.textLabel.text = action.name;
    cell.detailTextLabel.text = [WBUtils stringFromDate:action.date];
    cell.contentView.backgroundColor = (action.active ? [UIColor whiteColor] : [UIColor lightGrayColor]);
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HistoryAction *action = [[[HistoryManager sharedManager] historyPool] objectAtIndex:[indexPath row]];
    if ([action active]) {
        [[HistoryManager sharedManager] deactivateAction:action];
    } else {
        [[HistoryManager sharedManager] activateAction:action];
    }
}

- (void)updateHistoryView {
    [self.historyTableView reloadData];
}

- (void)dealloc {
    [[HistoryManager sharedManager] setDelegate:nil];
}
@end
