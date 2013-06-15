//
//  WBBoard.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBoard.h"
#import "WBPage.h"
#import "GLCanvasElement.h"
#import "BoardManager.h"
#import "HistoryManager.h"
#import "SettingManager.h"
#import "GSButton.h"
#import "HistoryView.h"

#define kToolBarItemWidth   (IS_IPAD ? 64 : 64)
#define kToolBarItemHeight  (IS_IPAD ? 64 : 64)
#define kPageCurlWidth      (IS_IPAD ? 64 : 64)
#define kPageCurlHeight     (IS_IPAD ? 99 : 99)

#define kHistoryViewTag     888
#define kPageCurlButtonTag  kHistoryViewTag+1

#define kCanvasButtonIndex  777
#define kTextButtonIndex    (kCanvasButtonIndex+1)
#define kHistoryButtonIndex (kCanvasButtonIndex+2)
#define kLockButtonIndex    (kCanvasButtonIndex+3)
#define kDoneButtonIndex    (kCanvasButtonIndex+4)

#define kWBSessionAnimationDuration 0.5

@interface WBBoard ()
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic) int currentPageIndex;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic) BOOL isTargetViewCurled;
- (void)selectPage:(WBPage *)page;

// Control for board
@property (nonatomic, strong) UIView         *toolLayer;
@end

@implementation WBBoard
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize previewImage = _previewImage;
@synthesize tags = _tags;
@synthesize pages = _pages;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize delegate = _delegate;
@synthesize isAnimating = _isAnimating;
@synthesize animationTimer = _animationTimer;
@synthesize isTargetViewCurled = _isTargetViewCurled;
@synthesize toolLayer = _toolLayer;

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
            [page setPageDelegate:self];
            [self selectPage:page];
            [self.pages addObject:page];
        }
        
        // There's always at least 1 page
        if ([self.pages count]) {
            [self selectPage:[self.pages objectAtIndex:self.currentPageIndex]]; // Select first page
        } else {
            [self addNewPage];
        }
        
        // [self initExportControl];
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = OPAQUE_HEXCOLOR(0xa8a8a8);
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"B_"];
        self.name = [NSString stringWithFormat:@"Whiteboard %@", [WBUtils getCurrentTime]];
        self.pages = [NSMutableArray new];
        [self addNewPage];
        
        [self initLayersWithFrame:self.view.frame];
        
        [[SettingManager sharedManager] setCurrentColorTab:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)initExportControl {
    GSButton *exportButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
    [exportButton setTitle:@"Export Page" forState:UIControlStateNormal];
    [exportButton setFrame:CGRectMake(self.view.frame.size.width-64,
                                      self.view.frame.size.height-64,
                                      64,
                                      64)];
    [exportButton addTarget:self action:@selector(exportPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportButton];
    [self.view sendSubviewToBack:exportButton];
}

- (int)numOfPages {
    return [self.pages count];
}

#pragma mark - Tool/Control for Board
- (void)initLayersWithFrame:(CGRect)frame {
    // Canvas/Text/History/Lock
    self.toolLayer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              frame.size.height-kToolBarItemHeight,
                                                              kToolBarItemWidth*4,
                                                              kToolBarItemHeight)];
    [self.toolLayer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.toolLayer];
    [self initToolBarButtonsWithFrame:frame];
}

- (void)initToolBarButtonsWithFrame:(CGRect)frame {
    GSButton *canvasButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [canvasButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/PencilButton.fw.png"]
                            forState:UIControlStateNormal];
    [canvasButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/CanvasButtonActive.fw.png"]
                            forState:UIControlStateSelected];
    [canvasButton setFrame:CGRectMake(kToolBarItemWidth*0, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [canvasButton addTarget:self action:@selector(newCanvas:) forControlEvents:UIControlEventTouchUpInside];
    [canvasButton setTag:kCanvasButtonIndex];
    [canvasButton setSelected:YES]; // Default is canvas button
    [self.toolLayer addSubview:canvasButton];
    
    GSButton *textButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [textButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/TextButton.fw.png"]
                          forState:UIControlStateNormal];
    [textButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/TextButtonActive.fw.png"]
                          forState:UIControlStateSelected];
    [textButton setFrame:CGRectMake(kToolBarItemWidth, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [textButton addTarget:self action:@selector(newText:) forControlEvents:UIControlEventTouchUpInside];
    [textButton setTag:kTextButtonIndex];
    [self.toolLayer addSubview:textButton];
    
    GSButton *historyButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/HistoryButton.fw.png"]
                             forState:UIControlStateNormal];
    [historyButton setFrame:CGRectMake(kToolBarItemWidth*2, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [historyButton addTarget:self action:@selector(showHistoryView) forControlEvents:UIControlEventTouchUpInside];
    [historyButton setTag:kHistoryButtonIndex];
    [self.toolLayer addSubview:historyButton];
    
    GSButton *lockButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [lockButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/MoveButton.fw.png"]
                          forState:UIControlStateNormal];
    [lockButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/MoveButtonActive.fw.png"]
                          forState:UIControlStateSelected];
    [lockButton setFrame:CGRectMake(kToolBarItemWidth*3, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [lockButton addTarget:self action:@selector(lockPage:) forControlEvents:UIControlEventTouchUpInside];
    [lockButton setTag:kLockButtonIndex];
    [self.toolLayer addSubview:lockButton];
    
    GSButton *pageCurlButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [pageCurlButton setImage:[UIImage imageNamed:@"Whiteboard.bundle/PageCurl.png"]
                    forState:UIControlStateNormal];
    [pageCurlButton setFrame:CGRectMake(frame.size.width-kPageCurlWidth,
                                        frame.size.height-kPageCurlHeight,
                                        kPageCurlWidth,
                                        kPageCurlHeight)];
    [pageCurlButton addTarget:self action:@selector(doneEditing)
             forControlEvents:UIControlEventTouchUpInside];
    [pageCurlButton setTag:kPageCurlButtonTag];
    [self.view addSubview:pageCurlButton];
}

#pragma mark - Pages Handler
- (void)addNewPage {
    WBPage *page = [[WBPage alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height)];
    [page setPageDelegate:self];
    [page select];
    
    [self.view addSubview:page];
    [self.pages addObject:page];
    [self setCurrentPageIndex:([self.pages count]-1)];
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

- (void)elementSelected:(WBBaseElement *)element {
    if ([element isKindOfClass:[CGCanvasElement class]]
        || [element isKindOfClass:[GLCanvasElement class]]) {
        [((GSButton *) [self.toolLayer viewWithTag:kCanvasButtonIndex]) setSelected:YES];
    } else if ([element isKindOfClass:[TextElement class]]) {
        [((GSButton *) [self.toolLayer viewWithTag:kTextButtonIndex]) setSelected:YES];
    }
}

- (void)elementDeselected:(WBBaseElement *)element {
    if ([element isKindOfClass:[CGCanvasElement class]]
        || [element isKindOfClass:[GLCanvasElement class]]) {
        [((GSButton *) [self.toolLayer viewWithTag:kCanvasButtonIndex]) setSelected:NO];
    } else if ([element isKindOfClass:[TextElement class]]) {
        [((GSButton *) [self.toolLayer viewWithTag:kTextButtonIndex]) setSelected:NO];
    }
}

#pragma mark - Export output data
- (void)showExportControl:(WBPage *)page {
    if (!self.isAnimating && !self.isTargetViewCurled) {
        self.isAnimating = YES;
        [UIView beginAnimations:kCurlUpAndDownAnimationID context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:page cache:YES];
        [UIView setAnimationDuration:1.4f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView commitAnimations];
    }
}

- (void)exportPage {
    [self doneEditingPage:[self currentPage]];
}

#pragma mark - Export output data
- (UIImage *)exportBoardToUIImage {
    return [[self currentPage] exportPageToImage];
}

#pragma mark - Tool Bar Buttons
- (void)newCanvas:(GSButton *)canvasButton {
    if ([[self currentPage] selectedElementView]
        && [[[self currentPage] selectedElementView] isKindOfClass:[GLCanvasElement class]]
        && ![[[self currentPage] selectedElementView] isTransformed]) {
        [[[self currentPage] selectedElementView] select];
    } else {
        GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [[self currentPage] addElement:canvasElement];
        [[HistoryManager sharedManager] addActionCreateElement:canvasElement forPage:[self currentPage]];
    }
}

- (void)newText:(GSButton *)textButton {
    if ([[self currentPage] selectedElementView]
        && [[[self currentPage] selectedElementView] isKindOfClass:[TextElement class]]
        && ![[[self currentPage] selectedElementView] isTransformed]) {
        [[[self currentPage] selectedElementView] select];
    } else {
        TextElement *textElement = [[TextElement alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [[self currentPage] addElement:textElement];
        [[HistoryManager sharedManager] addActionCreateElement:textElement forPage:[self currentPage]];
    }
}

- (void)lockPage:(GSButton *)lockButton {
    [lockButton setSelected:![lockButton isSelected]];
    [[self currentPage] setIsLocked:![[self currentPage] isLocked]];
    if (![[self currentPage] isLocked]) {
        [[self currentPage] focusOnTopElement];
    }
}

- (void)doneEditing {
    [[HistoryManager sharedManager] clearHistoryPool];
    if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
        [self.delegate doneEditingBoardWithResult:[self exportBoardToUIImage]];
    }
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    [UIView beginAnimations:kCurlUpAndDownAnimationID context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:YES];
    [UIView setAnimationDuration:kWBSessionAnimationDuration];
    [UIView commitAnimations];
}

#pragma mark - History View
- (void)showHistoryView {
    HistoryView *historyView = [[HistoryView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kToolBarItemHeight*4, self.view.frame.size.width, kToolBarItemHeight*4)];
    [historyView setTag:kHistoryViewTag];
    [self.view addSubview:historyView];
}

- (void)hideHistoryView {
    [[self.view viewWithTag:kHistoryViewTag] removeFromSuperview];
}

#pragma mark - Animation Page Curl
- (void)animationWillStart:(NSString *)animationID context:(void *)context {	
	self.isAnimating = YES;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.87
														   target:self
														 selector:@selector(stopCurl)
														 userInfo:nil
														  repeats:NO];
	return;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.isAnimating = NO;
    self.isTargetViewCurled = NO;
	self.isAnimating = NO;
}

- (void)stopCurl {
	[self.animationTimer invalidate];
	[self setAnimationTimer:nil];
    
    CFTimeInterval pausedTime = [[self currentPage].layer convertTime:CACurrentMediaTime() fromLayer:nil];
    [self currentPage].layer.speed = 0.0;
    [self currentPage].layer.timeOffset = pausedTime;
	
	self.isTargetViewCurled = YES;
	self.isAnimating = NO;
}

#pragma mark - Animation Show/Dismiss board
- (void)showMeWithAnimationFromController:(UIViewController *)controller {
    [controller presentViewController:self animated:NO completion:NULL];
    
    [UIView beginAnimations:kCurlUpAndDownAnimationID context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:YES];
    [UIView setAnimationDuration:kWBSessionAnimationDuration];
    [UIView commitAnimations];
    
    [[BoardManager sharedManager] createANewBoard:self];
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    [self hideHistoryView];
    [((GSButton *) [self.toolLayer viewWithTag:kTextButtonIndex]) setSelected:YES];
    //    NSDictionary* info = [aNotification userInfo];
    //    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //
    //
    //    [UIView animateWithDuration:0.2f animations:^{
    //        CGRect frame = CGRectMake(self.textToolLayer.frame.origin.x,
    //                                  self.frame.size.height-kToolBarItemHeight,
    //                                  self.textToolLayer.frame.size.width,
    //                                  self.textToolLayer.frame.size.height);
    //        frame.origin.y -= kbSize.height;
    //        self.textToolLayer.frame = frame;
    //    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    
    NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:[self.pages count]];
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
