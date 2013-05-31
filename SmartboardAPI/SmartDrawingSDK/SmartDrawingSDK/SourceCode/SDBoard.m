//
//  SDBoard.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDBoard.h"

@interface SDBoard ()
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) UIImageView *backgroundImageView;
- (void)selectPage:(SDPage *)page;
@end

@implementation SDBoard
@synthesize uid = _uid;
@synthesize pages = _pages;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        self.uid = [SDUtils generateUniqueId];
        self.pages = [[NSMutableArray alloc] init];
        
        // There's always at least 1 page
        [self addNewPage];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:@"Default.png"];
    }
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.backgroundImageView setImage:image];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    [[self.pages objectAtIndex:0] setBackgroundImage:image];
}

#pragma mark - Pages Handler
- (void)addNewPage {
    SDPage *page = [[SDPage alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [page setDelegate:self];
    [self selectPage:page];
    [self.pages addObject:page];
}

- (void)removePageWithId:(NSString *)uid {
    SDPage *pageToRemove = nil;
    for (SDPage *page in self.pages) {
        if ([page.uid isEqualToString:uid]) {
            pageToRemove = page;
            break;
        }
    }
    
    if (pageToRemove) {
        [self.pages removeObject:pageToRemove];
        [pageToRemove removeFromSuperview];
    }
}

- (void)rearrangePageFromIndex:(int)from toIndex:(int)to {
    if (from >= 0 && from < [self.pages count] && to >= 0 && to < [self.pages count]) {
        SDPage *pageToRearrange = [self.pages objectAtIndex:from];
        [self.pages removeObjectAtIndex:from];
        [self.pages insertObject:pageToRearrange atIndex:to];
    }
}

- (void)selectPage:(SDPage *)page {
    BOOL pageExisted = NO;
    for (SDPage *existedPage in self.pages) {
        if ([page.uid isEqualToString:existedPage.uid]) {
            pageExisted = YES;
            break;
        }
    }
    
    if (pageExisted) {
        [[page superview] bringSubviewToFront:page];
    } else {
        [self.view addSubview:page];
    }
    
    [page select];
}

- (void)pageSelected:(SDPage *)page {
    // Nothing to do right now
}

#pragma mark - Export output data
- (void)doneEditingPage:(SDPage *)page {
    if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
        [self.delegate doneEditingBoardWithResult:[self exportBoardToUIImage]];
    }
}

- (UIImage *)exportBoardToUIImage {
    if (self.backgroundImageView) {
        return [self.backgroundImageView image];
    }
    return nil;
}

#pragma mark - Life cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation
// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (NSUInteger)supportedInterfaceOrientations {
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
