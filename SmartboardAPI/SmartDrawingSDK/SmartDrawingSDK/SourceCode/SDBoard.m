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
        self.uid = [SDUtils generateUniqueId];
        self.pages = [[NSMutableArray alloc] init];
        
        SDPage *firstPage = [[SDPage alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
        [firstPage setDelegate:self];
        [self selectPage:firstPage];
        [firstPage select];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image {
    if (image) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.backgroundImageView setImage:image];
        [self.view addSubview:self.backgroundImageView];
        [self.view sendSubviewToBack:self.backgroundImageView];
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
}

- (void)pageSelected:(SDPage *)page {
    
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
