//
//  WBMenuContentView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/21/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBMenuContentView.h"
#import "SettingManager.h"
#import <QuartzCore/QuartzCore.h>

@interface WBMenuContentView () {
    UIView         *menuView;
    UITableView    *menuTableView;
    BOOL            isAnimationUp;
    BOOL            isAnimationDown;
    NSMutableArray *menuSections;
}
@end

@implementation WBMenuContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
        
        menuSections = [NSMutableArray new];
        
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, kOffsetForBouncing, frame.size.width, frame.size.height-kOffsetForBouncing)];
        [menuView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
        [menuView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [menuView.layer setBorderWidth:1];
        [menuView.layer setCornerRadius:5];
        [menuView setClipsToBounds:YES];
        [self addSubview:menuView];
        
        menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, menuView.frame.size.width, menuView.frame.size.height)];
        [menuTableView setBackgroundColor:[UIColor clearColor]];
        [menuTableView setDelegate:self];
        [menuTableView setDataSource:self];
        [menuTableView setShowsVerticalScrollIndicator:YES];
        [menuTableView setShowsHorizontalScrollIndicator:YES];
        [menuView addSubview:menuTableView];
    }
    return self;
}

#pragma mark - Animation
- (void)animateUp {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height/2];
    NSValue * to = [NSNumber numberWithFloat:-self.frame.size.height/2];
    NSString * keypath = @"position.y";
    
    [menuView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                             forKey:@"bounce"];
    [menuView.layer setValue:to forKeyPath:keypath];
    isAnimationUp = YES;
}

- (void)animateDown {
    NSValue * from = [NSNumber numberWithFloat:0];
    NSValue * to = [NSNumber numberWithFloat:(self.frame.size.height-kOffsetForBouncing)/2];
    NSString * keypath = @"position.y";
    
    [menuView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                             forKey:@"bounce"];
    [menuView.layer setValue:to forKeyPath:keypath];
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

#pragma mark - UITableView Datasource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kMenuHeaderHeight)];
    [headerView setBackgroundColor:[UIColor darkGrayColor]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, kMenuHeaderHeight)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return menuSections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kMenuHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMenuCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    return rowsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    if (rowsArray.count <= 0) return @"";
    WBMenuItem *item = rowsArray[0];
    return item.section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:25.0f];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    int sectionIndex = [indexPath section];
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    int rowIndex = [indexPath row];
    WBMenuItem *item = rowsArray[rowIndex];
    cell.textLabel.text = item.name;
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath section];
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    int rowIndex = [indexPath row];
    WBMenuItem *item = rowsArray[rowIndex];
    
    // TODO: is this fast enough that we can just do it every time, regardless of the item chosen? (e.g. Penultimate is able to do this super fast)
    UIImage *image = [self.delegate image];
    
    // TODO: use completion message (set as cell text, like PicCollage)
    WBCompletionBlock completionBlock = ^(NSString *message) {
        NSLog(@"completion message: %@", message);
    };
    
    // block should check validity of `image`
    item.block(image, completionBlock);
}

- (void)addMenuItem:(WBMenuItem *)item
{
    BOOL didAddItem = NO;
    for (NSMutableArray *a in menuSections)
    {
        if (a.count <= 0) continue;
        WBMenuItem *currentItem = [a objectAtIndex:0];
        if ([currentItem.section isEqualToString:item.section])
        {
            // `item` belongs in this section
            [a addObject:item];
            didAddItem = YES;
            break;
        }
    }
    if (didAddItem == NO)
    {
        // Create new section for `item`
        NSMutableArray *a = [NSMutableArray arrayWithObject:item];
        [menuSections addObject:a];
    }
}

@end
