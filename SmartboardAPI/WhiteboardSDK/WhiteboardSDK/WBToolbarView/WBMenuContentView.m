//
//  WBMenuContentView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/21/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBMenuContentView.h"
#import "SettingManager.h"
#import <QuartzCore/QuartzCore.h>

@interface WBMenuContentView() {
    UIView                 *menuView;
    UITableView            *menuTableView;
    BOOL                   isAnimationUp;
    BOOL                   isAnimationDown;
}
@end


@implementation WBMenuContentView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
        
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
    return [MENU_ARRAY count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0 && section < 4) {
        return kMenuHeaderHeight;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMenuCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [SAVING_ARRAY count];
        case 2:
            return [SHARING_ARRAY count];
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section > 0 && section < 3) {
        return [MENU_ARRAY objectAtIndex:section];
    }
    return @"";
    
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
    
    switch ([indexPath section]) {
        case 1:
            cell.textLabel.text = [SAVING_ARRAY objectAtIndex:[indexPath row]];
            break;
        case 2:
            cell.textLabel.text = [SHARING_ARRAY objectAtIndex:[indexPath row]];
            break;
        default:
            cell.textLabel.text = [MENU_ARRAY objectAtIndex:[indexPath section]];
            break;
    }
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(exitBoard)]) {
                [self.delegate exitBoard];
            }
            break;
        case 1:
            switch ([indexPath row]) {
                case 0:
                    // Save a Copy
                    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(saveACopy)]) {
                        [self.delegate saveACopy];
                    }
                    break;
                case 1:
                    // Save to Photos App
                    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(saveToPhotosApp)]) {
                        [self.delegate saveToPhotosApp];
                    }
                    break;
                case 2:
                    // Save to Evernote
                    break;
                case 3:
                    // Save to Google Drive
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch ([indexPath row]) {
                case 0:
                    // Share on Facebook
                    break;
                case 1:
                    // Share on Twitter
                    break;
                case 2:
                    // Upload to Online Gallery
                    break;
                case 3:
                    // Send in Email
                    break;
                case 4:
                    // Send in iMessage/MMS
                    break;
                default:
                    break;
            }
            break;
        case 3:
            // Delete Page
            break;
        case 4:
            // Credits
            break;
        case 5:
            // Help/FAQs
            break;
        case 6:
            // Contact Us
            break;
        default:
            break;
    }
}

@end
