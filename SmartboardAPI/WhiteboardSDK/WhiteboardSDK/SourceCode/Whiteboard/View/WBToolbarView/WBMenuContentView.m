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
        
        // default menu item
        [self addMenuItem:[WBMenuItem itemInSection:@"Navigation" name:@"Close drawing editor"/*@"Back to Organizer"*/ progressString:@"Closing editor..." blockWithoutImage:^(WBCompletionBlock completionBlock) {
            // this is kind of slow because it exports the page to an image before returning. that's ok for now.
            [self.delegate doneEditing]; // @required delegate method!
            completionBlock(@"Closing...");
        }]];
        
        //menuView = [[UIView alloc] initWithFrame:CGRectMake(0, kOffsetForBouncing, frame.size.width, frame.size.height-kOffsetForBouncing)];
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
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
    [menuTableView reloadData]; // resets "completed" menu items
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
    }
    
    // do this out here to ensure we reset the cell's state if it was temporarily completed before
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.enabled = YES;
    
    int sectionIndex = [indexPath section];
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    int rowIndex = [indexPath row];
    WBMenuItem *item = rowsArray[rowIndex];
    cell.textLabel.text = item.name;
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone)
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    int sectionIndex = [indexPath section];
    NSMutableArray *rowsArray = menuSections[sectionIndex]; // all rows in section
    int rowIndex = [indexPath row];
    WBMenuItem *item = rowsArray[rowIndex];
    
    // set progressString
    cell.textLabel.text = item.progressString;
    // note: we are intentionally NOT updating the data source so that when this table is refreshed, this message will go away
    // (it is a temporary message)
    
    // similarly, we want to temporarily disable selection for this row.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // grey out the item
    cell.textLabel.enabled = NO;
    
    // Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // use completion message (set as cell text, like PicCollage)
    WBCompletionBlock completionBlock = ^(NSString *message) {
        // update the cell's text
        cell.textLabel.text = message;
        // note: we are intentionally NOT updating the data source so that when this table is refreshed, this message will go away
        // (it is a temporary message)
        
        // similarly, we want to temporarily disable selection for this row.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // grey out the item
        cell.textLabel.enabled = NO;
    };
    
    if (item.blockWithImage) {
        
        // Re: -image - Penultimate is able to do this super fast
        // The more OpenGLES Views it has, the slower the function takes
        // More Texts or Images do not effect it much
        // This contains:
        //  - Export all OpenGLES Views into UIImage then add the UIImage as subview of OpenGLES View (it's called screenshot)
        //  - Render the current context of the current WBPage into the final UIImage
        //  - Remove all UIImages (screenshots) from all OpenGLES Views
        
        // If the delegate method is not @required, check if delegate is not nil and responds to selector first.
        // e.g. if ([self.delegate respondsToSelector:@selector(image)])
        // In this case, the delegate method is @required
        
        // This is actually kind of slow so let's try running it in the background
        // Cool, this seems to work well.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self.delegate image];
            
            // block should check validity of `image` and `completionBlock`
            // note: block execution doesn't take much time (and, at least in the case of "Save to Photo Library", is mostly asynchronous anyway)
            // so let's try running it on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                item.blockWithImage(image, completionBlock);
            });
        });
    }
    
    if (item.blockWithoutImage) {
        // by using dispatch_async we can allow the cell selection background to fade out
        dispatch_async(dispatch_get_main_queue(), ^{
            item.blockWithoutImage(completionBlock);
        });
    }
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

- (void)removeAllMenuItems
{
    [menuSections removeAllObjects];
}

@end
