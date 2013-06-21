//
//  WBAddMoreSelectionView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBAddMoreSelectionView.h"
#import "SettingManager.h"
#import <QuartzCore/QuartzCore.h>

#define ADD_MORE_ARRAY @[@"Use Camera", @"Add Photo", @"Add Text", @"Paste"]

@interface WBAddMoreSelectionView() {
    UIView                 *addMoreView;
    UITableView            *addMoreTableView;
    BOOL                   isAnimationUp;
    BOOL                   isAnimationDown;
}
@end

@implementation WBAddMoreSelectionView
@synthesize delegate = _delegate;
@synthesize isCanvasMode = _isCanvasMode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
        
        addMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, kOffsetForBouncing, frame.size.width, frame.size.height-kOffsetForBouncing)];
        [addMoreView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
        [addMoreView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [addMoreView.layer setBorderWidth:1];
        [addMoreView.layer setCornerRadius:5];
        [addMoreView setClipsToBounds:YES];
        [self addSubview:addMoreView];
        
        addMoreTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, addMoreView.frame.size.width, kAddMoreCellHeight*4)];
        [addMoreTableView setBackgroundColor:[UIColor clearColor]];
        [addMoreTableView setDelegate:self];
        [addMoreTableView setDataSource:self];
        [addMoreTableView setShowsVerticalScrollIndicator:YES];
        [addMoreTableView setShowsHorizontalScrollIndicator:YES];
        [addMoreView addSubview:addMoreTableView];

    }
    return self;
}

#pragma mark - Animation
- (void)animateUp {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height*1.3];
    NSValue * to = [NSNumber numberWithFloat:(self.frame.size.height+kOffsetForBouncing)/2];
    NSString * keypath = @"position.y";
    
    [addMoreView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                             forKey:@"bounce"];
    [addMoreView.layer setValue:to forKeyPath:keypath];
    isAnimationUp = YES;
}

- (void)animateDown {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height/2];
    NSValue * to = [NSNumber numberWithFloat:self.frame.size.height*2];
    NSString * keypath = @"position.y";
    
    [addMoreView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                              to:to
                                                      forKeyPath:keypath
                                                    withDuration:.6
                                                        delegate:self]
                             forKey:@"bounce"];
    [addMoreView.layer setValue:to forKeyPath:keypath];
    isAnimationDown = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (isAnimationUp) {
        isAnimationUp = NO;
    }
    
    if (isAnimationDown) {
        [self removeFromSuperview];
        isAnimationDown = NO;
    }
}

- (void)setIsCanvasMode:(BOOL)isCanvasMode {
    _isCanvasMode = isCanvasMode;
    [addMoreTableView reloadData];
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAddMoreCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ADD_MORE_ARRAY count];
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
    
    if ([indexPath row] == 2 && !self.isCanvasMode) {
        cell.textLabel.text = @"Brush";
    } else {
        cell.textLabel.text = [ADD_MORE_ARRAY objectAtIndex:[indexPath row]];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 0:
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addCameraFrom:)]) {
                [self.delegate addCameraFrom:self];
            }
            break;
        case 1:
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addPhotoFrom:)]) {
                [self.delegate addPhotoFrom:self];
            }
            break;
        case 2:
            if (!self.isCanvasMode) {
                if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addCanvasFrom:)]) {
                    [self.delegate addCanvasFrom:self];
                }
            } else {
                if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addTextFrom:)]) {
                    [self.delegate addTextFrom:self];
                }
            }
        case 3:
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addPasteFrom:)]) {
                [self.delegate addPasteFrom:self];
            }
            break;
        default:
            break;
    }
    [self animateDown];
}

@end
