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

#define kUndoLabelTag 100

@interface HistoryView() {
    UIView                 *historyView;
    UITableView            *historyTableView;
    BOOL                   isAnimationUp;
    BOOL                   isAnimationDown;
}
@end

@implementation HistoryView
@synthesize currentPage = _currentPage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
        
        historyView = [[UIView alloc] initWithFrame:CGRectMake(0, kOffsetForBouncing, frame.size.width, frame.size.height-kOffsetForBouncing)];
        [historyView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
        [historyView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [historyView.layer setBorderWidth:1];
        [historyView.layer setCornerRadius:5];
        [historyView setClipsToBounds:YES];
        [self addSubview:historyView];
        
        UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kHistoryTitleHeight)];
        [historyLabel setBackgroundColor:[UIColor clearColor]];
        [historyLabel setText:@"Previous actions"];
        [historyLabel setTextAlignment:NSTextAlignmentCenter];
        [historyLabel setTextColor:[UIColor darkGrayColor]];
        [historyLabel setFont:[UIFont systemFontOfSize:25.0f]];
        [historyLabel.layer setBorderWidth:1];
        [historyLabel.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [historyView addSubview:historyLabel];
        
        historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHistoryTitleHeight, historyView.frame.size.width, kHistoryCellHeight*4)];
        [historyTableView setBackgroundColor:[UIColor clearColor]];
        [historyTableView setDelegate:self];
        [historyTableView setDataSource:self];
        [historyTableView setShowsVerticalScrollIndicator:YES];
        [historyTableView setShowsHorizontalScrollIndicator:YES];
        [historyView addSubview:historyTableView];
        
        [[HistoryManager sharedManager] setDelegate:self];
    }
    return self;
}

#pragma mark - Animation
- (void)animateUp {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height/2];
    NSValue * to = [NSNumber numberWithFloat:-self.frame.size.height/2];
    NSString * keypath = @"position.y";
    
    [historyView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                                 forKey:@"bounce"];
    [historyView.layer setValue:to forKeyPath:keypath];
    isAnimationUp = YES;
}

- (void)animateDown {
    NSValue * from = [NSNumber numberWithFloat:0];
    NSValue * to = [NSNumber numberWithFloat:(self.frame.size.height-kOffsetForBouncing)/2];
    NSString * keypath = @"position.y";
    
    [historyView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                                 forKey:@"bounce"];
    [historyView.layer setValue:to forKeyPath:keypath];
    isAnimationDown = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (isAnimationUp) {
        [self removeFromSuperview];
        isAnimationUp = NO;
    }
    
    if (isAnimationDown) {
        isAnimationDown = NO;
    }
}

- (void)reloadData {
    [historyTableView reloadData];
}

#pragma mark - UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHistoryCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Get the history for that page
    NSMutableArray *historyForPage = [[[HistoryManager sharedManager] historyPool] objectForKey:[self currentPage].uid];
    int count = [historyForPage count];
    return (count == 0) ? 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:25.0f];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UILabel *undoLabel = [[UILabel alloc] init];
        [undoLabel setText:@"Undo"];
        [undoLabel setTextColor:[UIColor whiteColor]];
        [undoLabel setBackgroundColor:[UIColor clearColor]];
        [undoLabel setTextAlignment:NSTextAlignmentCenter];
        [undoLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [undoLabel setFrame:CGRectMake(tableView.frame.size.width-kHistoryCellHeight, 0, kHistoryCellHeight, kHistoryCellHeight)];
        [undoLabel setTag:kUndoLabelTag];
        [undoLabel setHidden:YES];
        [cell addSubview:undoLabel];
    }
    
    // Get the history for that page
    NSMutableArray *historyForPage = [[[HistoryManager sharedManager] historyPool] objectForKey:[self currentPage].uid];
    
    if ([historyForPage count] == 0) {
        cell.textLabel.text = @"No action";
        cell.detailTextLabel.text = @"";
        [cell viewWithTag:kUndoLabelTag].hidden = YES;
        
    } else {
        HistoryAction *action = [historyForPage objectAtIndex:[indexPath row]];
        cell.textLabel.text = action.name;
        cell.detailTextLabel.text = [WBUtils dateDiffFromDate:action.date];
        cell.contentView.backgroundColor = (action.active ? [UIColor clearColor] : [UIColor lightGrayColor]);
        cell.textLabel.textColor = (action.active ? [UIColor darkGrayColor] : [UIColor whiteColor]);
        cell.detailTextLabel.textColor = (action.active ? [UIColor lightGrayColor] : [UIColor whiteColor]);
        if (action.active) {
            [cell viewWithTag:kUndoLabelTag].hidden = YES;
        } else {
            [cell viewWithTag:kUndoLabelTag].hidden = NO;
        }
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the history for that page
    NSMutableArray *historyForPage = [[[HistoryManager sharedManager] historyPool] objectForKey:[self currentPage].uid];
    
    if ([historyForPage count] == 0) {
        
    } else {
        HistoryAction *currentAction = [historyForPage objectAtIndex:[indexPath row]];
        // Not last action
        if ([indexPath row] < [historyForPage count]-1) {
            if ([currentAction active]) {
                HistoryAction *nextAction = [historyForPage objectAtIndex:([indexPath row]+1)];
                if ([nextAction active]) {
                    [[HistoryManager sharedManager] deactivateAction:nextAction forPage:self.currentPage];
                }
            } else {
                [[HistoryManager sharedManager] activateAction:currentAction forPage:self.currentPage];
            }
            
        } else { // Last action, so we need to activate or deactivate it immediately
            if ([currentAction active]) {
                [[HistoryManager sharedManager] deactivateAction:currentAction forPage:self.currentPage];
            } else {
                [[HistoryManager sharedManager] activateAction:currentAction forPage:self.currentPage];
            }
        }
    }
    [tableView reloadData];
}

- (void)updateHistoryView {
    [historyTableView reloadData];
}

- (void)dealloc {
    [[HistoryManager sharedManager] setDelegate:nil];
}
@end
