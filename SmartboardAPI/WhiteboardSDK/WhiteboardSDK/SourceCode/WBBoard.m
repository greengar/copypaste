//
//  SDBoard.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBoard.h"
#import "CanvasElement.h"
#import "BoardManager.h"

@interface WBBoard ()
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic) int currentPageIndex;
@property (nonatomic, strong) UIImage *backgroundImage;
- (void)selectPage:(WBPage *)page;
@end

@implementation WBBoard
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize previewImage = _previewImage;
@synthesize tags = _tags;
@synthesize pages = _pages;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize backgroundImage = _backgroundImage;
@synthesize delegate = _delegate;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.view.frame = CGRectFromString([dictionary objectForKey:@"element_default_frame"]);
        self.view.backgroundColor = [UIColor clearColor];
        self.uid = [dictionary objectForKey:@"board_uid"];
        self.name = [dictionary objectForKey:@"board_name"];
        self.pages = [NSMutableArray new];
        
        NSMutableArray *pages = [dictionary objectForKey:@"board_pages"];
        for (NSDictionary *pageDict in pages) {
            WBPage *page = [WBPage loadFromDict:pageDict];
            [page setDelegate:self];
            [self selectPage:page];
            [self.pages addObject:page];
        }
        
        // There's always at least 1 page
        if ([self.pages count]) {
            [self selectPage:[self.pages objectAtIndex:self.currentPageIndex]]; // Select first page
        } else {
            [self addNewPage];
        }
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"B_"];
        self.name = [NSString stringWithFormat:@"Whiteboard %@", [WBUtils getCurrentTime]];
        self.pages = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.pages count]) {
        // There's always at least 1 page
        [self addNewPage];
    }
}

- (void)setBackgroundImage:(UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:@"Whiteboard.bundle/DefaultBackground.png"];
    }
    switch ([WBUtils getBuildVersion]) {
        case 1: {
            CanvasElement *canvasView = [[CanvasElement alloc] initWithFrame:CGRectMake(0,
                                                                                        0,
                                                                                        self.view.frame.size.width,
                                                                                        self.view.frame.size.height)
                                                                       image:image];
            [canvasView setDelegate:self];
            [self.view addSubview:canvasView];
        }   break;
            
        default: {
            _backgroundImage = image;
        }   break;
    }
}

- (int)numOfPages {
    return [self.pages count];
}

#pragma mark - Pages Handler
- (void)addNewPage {
    WBPage *page = [[WBPage alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height)];
    [page setBackgroundImage:self.backgroundImage];
    [page setDelegate:self];
    [self selectPage:page];
    [self.pages addObject:page];
    self.currentPageIndex = [self.pages count]-1;
}

- (void)removePageWithId:(NSString *)uid {
    WBPage *pageToRemove = nil;
    for (WBPage *page in self.pages) {
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
        WBPage *pageToRearrange = [self.pages objectAtIndex:from];
        [self.pages removeObjectAtIndex:from];
        [self.pages insertObject:pageToRearrange atIndex:to];
    }
}

- (void)selectPage:(WBPage *)page {
    BOOL pageExisted = NO;
    for (WBPage *existedPage in self.pages) {
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

- (void)pageSelected:(WBPage *)page {
    // Nothing to do right now
}

- (WBPage *)currentPage {
    return [self pageAtIndex:self.currentPageIndex];
}

- (WBPage *)pageAtIndex:(int)index {
    return [self.pages objectAtIndex:index];
}

#pragma mark - Export output data
- (void)doneEditingPage:(WBPage *)page {
    if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
        DLog(@"%d", [BoardManager writeBoardToFile:self]);
        [self.delegate doneEditingBoardWithResult:[self exportBoardToUIImage]];
    }
}

- (UIImage *)exportBoardToUIImage {
    return [[self currentPage] exportPageToImage];
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    
    NSMutableArray *pageArray = [NSMutableArray new];
    for (WBPage *page in self.pages) {
        NSDictionary *pageDict = [page saveToDict];
        [pageArray addObject:pageDict];
    }
    
    [dict setObject:pageArray forKey:@"board_pages"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBoard *)loadFromDict:(NSDictionary *)dict {
    WBBoard *board = [[WBBoard alloc] initWithDict:dict];
    return board;
}

#pragma mark - Build version 1.0: just OpenGL View:
- (void)elementDeselected:(WBBaseElement *)element {
    CanvasElement *canvasView = (CanvasElement *) element;
    MainPaintingView *drawingView = (MainPaintingView *) [canvasView contentView];
    if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
        [self.delegate doneEditingBoardWithResult:[drawingView glToUIImage]];
    }
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
