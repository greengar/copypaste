//
//  WBBoard.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBBoard.h"
#import "WBPage.h"
#import "GLCanvasElement.h"
#import "BackgroundElement.h"
#import "HistoryManager.h"
#import "HistoryElement.h"
#import "SettingManager.h"
#import "PaintingManager.h"
#import "GSButton.h"
#import "HistoryView.h"
#import "WBMenubarView.h"
#import "WBToolbarView.h"
#import "WBToolMonitorView.h"
#import "WBAddMoreSelectionView.h"
#import "WBMenuContentView.h"
#import "AGImagePickerController.h"
#import "AGIPCToolbarItem.h"
#import "WBPopoverView.h"
#import "HistoryElementCreated.h"
#import "HistoryElementDeleted.h"
#import "HistoryElementTransform.h"
#import "HistoryElementTextChanged.h"
#import "HistoryElementTextColorChanged.h"
#import "HistoryElementTextFontChanged.h"
#import "HistoryElementCanvasDraw.h"
#import "MultiStrokePaintingCmd.h"
#import "GSSVProgressHUD.h"
#import "UIColor+GSString.h"
#import <dispatch/dispatch.h>
#import "UIImageExtras.h"

#define kToolBarItemWidth   (IS_IPAD ? 64 : 64)
#define kToolBarItemHeight  (IS_IPAD ? 64 : 64)

#define kToolMonitorTag     888

#define kPreviousButtonTag  999
#define kNextButtonTag      kPreviousButtonTag+1
#define kPageLabelTag       kPreviousButtonTag+2

#define kCanvasButtonIndex  777
#define kTextButtonIndex    (kCanvasButtonIndex+1)
#define kHistoryButtonIndex (kCanvasButtonIndex+2)
#define kLockButtonIndex    (kCanvasButtonIndex+3)
#define kDoneButtonIndex    (kCanvasButtonIndex+4)

#define kWBSessionAnimationDuration 0.5

#define kCurlUpAndDownAnimationKey @"kCurlUpAndDownAnimation%d"
#define kShowExportBehindCurlDuration 1.4f
#define kCurlAnimationShouldStopAfter (IS_IPAD ? 0.6f : 0.7f)
#define kShowNewPageWithCurlDownDuration 0.7f

@interface WBBoard () <WBPageDelegate, WBToolbarDelegate, WBToolMonitorDelegate, WBMenubarDelegate, WBAddMoreSelectionDelegate, WBMenuContentViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AGImagePickerControllerDelegate, WBPopoverViewDelegate>
{
    BOOL isPageCurlAnimating;
    BOOL isPageCurled;
    float pageUpSpeed;
    float pageUpTime;
    BOOL wantToTurnToPreviousPage;
    WBMenuContentView       *menuContentView;
    HistoryView             *historyView;
    WBAddMoreSelectionView  *addMoreView;
    WBPopoverView           *addMorePopoverView;
}

- (void)selectPage:(WBPage *)page;

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic) int currentPageIndex;

// Control for board
@property (nonatomic, strong) WBMenubarView             *menubarView;
@property (nonatomic, strong) WBToolbarView             *toolbarView;
@property (nonatomic, strong) GSButton                  *pageCurlButton;
@property (nonatomic, strong) UIView                    *pageHolderView;
@property (nonatomic, strong) UIView                    *exportControlView;
@property (nonatomic, strong) UIPopoverController       *addPhotoPopover;
@property (nonatomic)         dispatch_queue_t          backgroundQueue;
@end

@implementation WBBoard
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize previewImage = _previewImage;
@synthesize tags = _tags;
@synthesize pages = _pages;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize delegate = _delegate;
@synthesize menubarView = _menubarView;
@synthesize toolbarView = _toolbarView;
@synthesize pageHolderView = _pageHolderView;
@synthesize pageCurlButton = _pageCurlButton;
@synthesize exportControlView = _exportControlView;
@synthesize backgroundQueue = _backgroundQueue;

// Designated initalizer - this method should always be called when creating a WBBoard
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.backgroundQueue = dispatch_queue_create("com.greengar.WhiteboardSDK", NULL);
        
        self.view.backgroundColor = [UIColor darkGrayColor];
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"B_"];
        self.name = [NSString stringWithFormat:@"Whiteboard %@", [WBUtils getCurrentTime]];
        self.pages = [NSMutableArray new];
        
        [self initLayersWithFrame:self.view.frame]; // initializes self.menubarView
        
        [[SettingManager sharedManager] setCurrentColorTab:0];
        
        // TODO: Implement the Right Side Panel
        // [self initPageCurlControlWithFrame:self.view.frame];
        
        // Menu Content View
        float kMenuViewHeight = self.view.frame.size.height/2;
        int menuContentHeight = kMenuViewHeight;
        WBMenubarView *menubar = self.menubarView;
        menuContentView = [[WBMenuContentView alloc] initWithFrame:CGRectMake(menubar.frame.origin.x, menubar.frame.origin.y+menubar.frame.size.height, menubar.frame.size.width*1.25, menuContentHeight)];
        [menuContentView setDelegate:self];
        
        // History Content View
        int historyHeight = kHistoryViewHeight;
        historyView = [[HistoryView alloc] initWithFrame:CGRectMake(menubar.frame.origin.x, menubar.frame.origin.y+menubar.frame.size.height, menubar.frame.size.width, historyHeight)];
        
        // Add More ContentView
        int addMoreHeight = kAddMoreViewHeight;
        WBToolbarView *toolbar = self.toolbarView;
        addMoreView = [[WBAddMoreSelectionView alloc] initWithFrame:CGRectMake(toolbar.frame.origin.x+toolbar.frame.size.width-kAddMoreCellHeight*3, toolbar.frame.origin.y-addMoreHeight, kAddMoreCellHeight*3, addMoreHeight)];
        [addMoreView setDelegate:self];
    }
    return self;
}

- (id)initWithDelegate:(id<WBBoardDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.pages count]) {
        [self addNewPage];
    }
}

- (void)addMenuItem:(WBMenuItem *)item {
    [menuContentView addMenuItem:item];
}

- (void)doneEditing {
    [self exitBoardWithResult:YES];
}

- (int)numOfPages {
    return [self.pages count];
}

- (void)lockBoard {
    [[SettingManager sharedManager] setViewOnly:YES];
}

#pragma mark - Tool/Control for Board
- (void)initLayersWithFrame:(CGRect)frame {
    // Page Holder
    self.pageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.pageHolderView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.pageHolderView];
    
    // Menubar (Menu/Undo/History)
    float leftMargin = 25;
    float topMargin = 25;
    float topMenubarHeight = 74;
    float topMenubarButtonWidth = 81;
    float topMenubarWidth = topMenubarButtonWidth * 3;
    self.menubarView = [[WBMenubarView alloc] initWithFrame:CGRectMake(leftMargin, topMargin, topMenubarWidth, topMenubarHeight)];
    self.menubarView.delegate = self;
    self.menubarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.menubarView];
    
    // Toolbar (Canvas/Plus/Move/Color History Tray)
    float bottomToolbarHeight = 74;
    float bottomMargin = 26;
    float bottomToolbarWidth = 600;
    self.toolbarView = [[WBToolbarView alloc] initWithFrame:CGRectMake(leftMargin, self.view.frame.size.height-bottomToolbarHeight-bottomMargin, bottomToolbarWidth, bottomToolbarHeight)];
    self.toolbarView.delegate = self;
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.toolbarView];
}

#pragma mark - Pages Handler
- (void)addNewPage {
    WBPage *page = [[WBPage alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height)];
    [page setPageDelegate:self];
    
    [self.pageHolderView addSubview:page];
    [self.pages addObject:page];
    [self setCurrentPageIndex:([self.pages count]-1)];
    
    if ([self.delegate respondsToSelector:@selector(didAddNewPageWithUid:boardUid:)]) {
        [self.delegate didAddNewPageWithUid:page.uid
                               boardUid:self.uid];
    }
    
    [self initBaseCanvasElement];
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
        [self.pageHolderView bringSubviewToFront:page];
    } else {
        [self.pageHolderView addSubview:page];
    }
}

- (void)pageSelected:(WBPage *)page {
    // Nothing to do right now
}

- (void)pageUnlocked:(WBPage *)page {
    [self.toolbarView didActivatedMove:NO];
}

- (WBPage *)currentPage {
    return [self pageAtIndex:self.currentPageIndex];
}

- (WBPage *)pageAtIndex:(int)index {
    if (index >= 0 && index < [self.pages count]) {
        return [self.pages objectAtIndex:index];
    }
    THROW_EXCEPTION_TYPE(ArrayIndexOutOfBoundException);
    return nil;
}

- (void)elementSelected:(WBBaseElement *)element {
    
}

- (void)elementDeselected:(WBBaseElement *)element {
    
}

#pragma mark - Export output data
- (void)initPageCurlControlWithFrame:(CGRect)frame {
    // Page Curl Button
    float pageCurlWidth = 50;
    float pageCurlHeight = 74;
    self.pageCurlButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [self.pageCurlButton setImage:[UIImage imageNamed:@"Whiteboard.bundle/PageCurl.png"]
                         forState:UIControlStateNormal];
    [self.pageCurlButton setFrame:CGRectMake(frame.size.width-pageCurlWidth, frame.size.height-pageCurlHeight,
                                             pageCurlWidth, pageCurlHeight)];
    [self.pageCurlButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.pageCurlButton addTarget:self action:@selector(performPageCurlUp:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageCurlButton];
    
    float exportButtonSize = 79;
    float exportPageLabelHeight = 30;
    float rightMargin = 26;
    float bottomMargin = 26;
    self.exportControlView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-3*exportButtonSize-rightMargin, self.view.frame.size.height-exportButtonSize-exportPageLabelHeight-bottomMargin, exportButtonSize*3, exportButtonSize+exportPageLabelHeight)];
    self.exportControlView.layer.cornerRadius = 5;
    self.exportControlView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.exportControlView.layer.borderWidth = 1;
    self.exportControlView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [self.pageHolderView addSubview:self.exportControlView];
        
    GSButton *nextButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton setTag:kNextButtonTag];
    [nextButton setFrame:CGRectMake(self.exportControlView.frame.size.width-exportButtonSize, exportPageLabelHeight,
                                    exportButtonSize, exportButtonSize)];
    [nextButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.exportControlView addSubview:nextButton];
    
    GSButton *previousButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:OrangeButtonStyle];
    [previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [previousButton setTag:kPreviousButtonTag];
    [previousButton setFrame:CGRectMake(self.exportControlView.frame.size.width-exportButtonSize*2, exportPageLabelHeight,
                                        exportButtonSize, exportButtonSize)];
    [previousButton addTarget:self action:@selector(previousPage) forControlEvents:UIControlEventTouchUpInside];
    [self.exportControlView addSubview:previousButton];
    
    GSButton *cancelButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GrayButtonStyle];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(self.exportControlView.frame.size.width-exportButtonSize*3, exportPageLabelHeight,
                                      exportButtonSize, exportButtonSize)];
    [cancelButton addTarget:self action:@selector(performPageCurlDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.exportControlView addSubview:cancelButton];
    
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.exportControlView.frame.size.width, exportPageLabelHeight)];
    [pageLabel setTag:kPageLabelTag];
    [pageLabel setBackgroundColor:[UIColor clearColor]];
    [pageLabel setTextColor:[UIColor darkGrayColor]];
    [pageLabel setTextAlignment:NSTextAlignmentCenter];
    [pageLabel setText:[NSString stringWithFormat:@"Page: %d/%d", self.currentPageIndex+1, [self.pages count]]];
    [self.exportControlView addSubview:pageLabel];
    
    [self.exportControlView setHidden:YES];
    [self.pageHolderView sendSubviewToBack:self.exportControlView];
}

- (void)performPageCurlUp:(GSButton *)button {
    if (!isPageCurlAnimating && !isPageCurled) {
        isPageCurlAnimating = YES;
        [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, [self currentPageIndex]] context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                               forView:[self currentPage]
                                 cache:YES];
        [UIView setAnimationDuration:kShowExportBehindCurlDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView commitAnimations];
        
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self hideAllControl];
            [self showExportControl];
            [[self currentPage] setHidden:YES];
        });
        
        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kCurlAnimationShouldStopAfter * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){            
            CFTimeInterval pausedTime = [[self currentPage].layer convertTime:CACurrentMediaTime()
                                                                    fromLayer:nil];
            pageUpSpeed = [self currentPage].layer.speed;
            [self currentPage].layer.speed = 0.0;
            pageUpTime = [self currentPage].layer.timeOffset;
            [self currentPage].layer.timeOffset = pausedTime;

            isPageCurled = YES;
            isPageCurlAnimating = NO;
        });
    }
}

- (void)performPageCurlDown:(GSButton *)button {
    if (!isPageCurlAnimating && isPageCurled) {
		isPageCurlAnimating = YES;
        
		CFTimeInterval pausedTime = [[self currentPage].layer timeOffset];
		[self currentPage].layer.speed = 1.0;
		[self currentPage].layer.timeOffset = 0.0;
		[self currentPage].layer.beginTime = 0.0;
		CFTimeInterval timeSincePause = [[self currentPage].layer convertTime:CACurrentMediaTime()
                                                                    fromLayer:nil]-pausedTime;
		[self currentPage].layer.beginTime = timeSincePause-2*(kShowExportBehindCurlDuration-kCurlAnimationShouldStopAfter);
		
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showAllControl];
            [self hideExportControl];
            [[self currentPage] setHidden:NO];
            
            isPageCurled = NO;
            isPageCurlAnimating = NO;
        });
	}
}

- (void)previousPage {
    isPageCurlAnimating = YES;
    wantToTurnToPreviousPage = YES;
    CFTimeInterval pausedTime = [[self currentPage].layer timeOffset];
    [self currentPage].layer.speed = 1.0;
    [self currentPage].layer.timeOffset = 0.0;
    [self currentPage].layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [[self currentPage].layer convertTime:CACurrentMediaTime()
                                                                fromLayer:nil]-pausedTime;
    [self currentPage].layer.beginTime = timeSincePause-2*(kShowExportBehindCurlDuration-kCurlAnimationShouldStopAfter);
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self currentPage] setHidden:NO];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (wantToTurnToPreviousPage) {
        wantToTurnToPreviousPage = NO;
        
        // Add previous page
        if (self.currentPageIndex > 0) {
            WBPage *previousPage = [self.pages objectAtIndex:(self.currentPageIndex-1)];
            [self.pageHolderView addSubview:previousPage];
            [previousPage setHidden:YES];
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [previousPage setHidden:NO];
                [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, [self currentPageIndex]] context:nil];
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                                       forView:[self currentPage]
                                         cache:YES];
                [UIView setAnimationDuration:kShowNewPageWithCurlDownDuration];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationRepeatAutoreverses:NO];
                [UIView commitAnimations];
            });
        }
        
        // Now current index is the previous page index
        self.currentPageIndex--;
        
        double delayInSeconds = kShowNewPageWithCurlDownDuration-0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showAllControl];
            [self hideExportControl];
            isPageCurled = NO;
            isPageCurlAnimating = NO;
        });
        
        // Remove pages after next page
        for (int i = self.currentPageIndex+2; i < [self.pages count]; i++) {
            WBPage *next2Page = [self.pages objectAtIndex:i];
            [next2Page setHidden:NO];
            [next2Page removeFromSuperview];
        }
    }
}

- (void)nextPage {
    isPageCurlAnimating = YES;
    [self showAllControl];
    [self hideExportControl];
    
    CFTimeInterval pausedTime = [[self currentPage].layer timeOffset];
    [self currentPage].layer.speed = pageUpSpeed;
    [self currentPage].layer.timeOffset = 0.0;
    [self currentPage].layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [[self currentPage].layer convertTime:CACurrentMediaTime() fromLayer:nil]-pausedTime;
    [self currentPage].layer.beginTime = timeSincePause;
    
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self currentPage].layer removeAllAnimations];
        [[self currentPage] removeFromSuperview];
        
        // Last page, so add a new page
        if (self.currentPageIndex == [self.pages count]-1) {
            [self addNewPage];
            
        // Otherwise, add the next page
        } else {
            WBPage *nextPage = [self.pages objectAtIndex:(self.currentPageIndex+1)];
            [self.pageHolderView addSubview:nextPage];
            
            // Now current index is the next page index
            self.currentPageIndex++;
        }
        
        // Remove the previous page
        WBPage *previousPage = [self.pages objectAtIndex:(self.currentPageIndex-1)];
        [previousPage setHidden:NO];
        [previousPage removeFromSuperview];
        
        // Add the page after the next page for showing page curl animation
        if (self.currentPageIndex+1 < [self.pages count]) {
            WBPage *nextPage = [self.pages objectAtIndex:(self.currentPageIndex+1)];
            [nextPage setHidden:NO];
            [self.pageHolderView addSubview:nextPage];
            [self.pageHolderView sendSubviewToBack:nextPage];
        }
        
        [self showAllControl];
        
        isPageCurled = NO;
        isPageCurlAnimating = NO;
    });
}

- (void)showExportControl {
    [self.pageHolderView bringSubviewToFront:[self exportControlView]];
    [self.pageHolderView bringSubviewToFront:[self currentPage]];
    [[self exportControlView] setHidden:NO];
    [(UILabel *)[self.exportControlView viewWithTag:kPageLabelTag] setText:[NSString stringWithFormat:@"Page: %d/%d", self.currentPageIndex+1, [self.pages count]]];
    ((UIButton *) [self.exportControlView viewWithTag:kPreviousButtonTag]).enabled = ([self currentPageIndex] > 0);
    
    if ([[SettingManager sharedManager] viewOnly]) {
        ((UIButton *) [self.exportControlView viewWithTag:kNextButtonTag]).enabled = ([self currentPageIndex] < [self.pages count]-1);
        [((UIButton *) [self.exportControlView viewWithTag:kNextButtonTag]) setTitle:@"Next"
                                                                            forState:UIControlStateNormal];
    } else {
        ((UIButton *) [self.exportControlView viewWithTag:kNextButtonTag]).enabled = YES;
        [((UIButton *) [self.exportControlView viewWithTag:kNextButtonTag]) setTitle:(([self currentPageIndex] < [self.pages count]-1) ? @"Next" : @"New")
                                                                            forState:UIControlStateNormal];
    }
}

- (void)hideExportControl {
    [[self exportControlView] setHidden:YES];
}

- (void)showAllControl {
    [[self menubarView] setHidden:NO];
    [[self toolbarView] setHidden:NO];
    [[self pageCurlButton] setHidden:NO];
}

- (void)hideAllControl {
    [self forceHideColorSpectrum];
    [[self menubarView] setHidden:YES];
    [[self toolbarView] setHidden:YES];
    [[self pageCurlButton] setHidden:YES];
}

#pragma mark - Export output data
- (UIImage *)exportBoardToUIImage {
    UIImage *fullresolutionImage = [[self currentPage] exportPageToImage];
    self.previewImage = [fullresolutionImage cropCenterAndScaleImageToSize:CGSizeMake(kThumbnailSize, kThumbnailSize)];
    return fullresolutionImage;
}

#pragma mark - Menu Bar Buttons

- (void)menuButtonTappedFrom:(UIView *)menubar {
    float centerOfMenuButton = menubar.frame.origin.x + menubar.frame.size.width / 6;
    float bottom = menubar.frame.origin.y + menubar.frame.size.height;
    CGPoint point = CGPointMake(centerOfMenuButton - 1, bottom);
    [WBPopoverView showPopoverAtPoint:point inView:self.view withContentView:menuContentView delegate:self];
    [self.menubarView didShowMenuView:YES];
}

// Delegate receives this call once the popover has begun the dismissal animation
- (void)popoverViewDidDismiss:(WBPopoverView *)popoverView {
    [self.menubarView didShowMenuView:NO];
    [self.menubarView didShowHistoryView:NO];
    [self.toolbarView didShowAddMoreView:NO];
}

- (void)exitBoard {
    [self exitBoardWithResult:NO];
}

- (void)saveACopy {
    
}

- (void)saveToPhotosApp {
    
}

- (UIImage *)image
{
    return [[self currentPage] exportPageToImage];
}

- (void)shareOnFacebook {

}

- (void)performUndo {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    // Get the history for that page
    NSMutableArray *historyForPage = [[[HistoryManager sharedManager] historyPool] objectForKey:[self currentPage].uid];
    
    for (int i = [historyForPage count]-1; i > 0; i--) {
        HistoryElement *action = [historyForPage objectAtIndex:i];
        if (action.active) {
            [[HistoryManager sharedManager] deactivateAction:action forPage:[self currentPage]];
            break;
        }
    }
}

- (void)historyButtonTappedFrom:(UIView *)menubar {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    float centerOfMenuButton = menubar.frame.origin.x + menubar.frame.size.width*5/6;
    float bottom = menubar.frame.origin.y + menubar.frame.size.height;
    CGPoint point = CGPointMake(centerOfMenuButton - 1, bottom);
    [historyView setCurrentPage:[self currentPage]];
    [historyView reloadData];
    [WBPopoverView showPopoverAtPoint:point inView:self.view withContentView:historyView delegate:self];
    [self.menubarView didShowHistoryView:YES];
}

#pragma mark - Tool Bar Buttons
- (void)canvasButtonTappedFrom:(UIView *)toolbar {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    if (![self.view viewWithTag:kToolMonitorTag]) {
        int monitorHeight = kWBToolMonitorHeight+kOffsetForBouncing;
        WBToolMonitorView *toolMonitorView = [[WBToolMonitorView alloc] initWithFrame:CGRectMake(toolbar.frame.origin.x,
                                                                                                 toolbar.frame.origin.y-monitorHeight,
                                                                                                 toolbar.frame.size.width,
                                                                                                 monitorHeight)];
        [toolMonitorView setTag:kToolMonitorTag];
        [toolMonitorView setDelegate:self];
        [self.view addSubview:toolMonitorView];
        [toolMonitorView animateUp];

        if ([[[self currentPage] currentElement] isKindOfClass:[TextElement class]]) {
            [toolMonitorView setTextMode:YES];
            [toolMonitorView setCurrentFont:((TextElement *) [[self currentPage] currentElement]).myFontName];
        } else {
            [toolMonitorView setTextMode:NO];
        }
        [self.toolbarView didShowMonitorView:YES];
        
    } else {
        [self forceHideColorSpectrum];
    }
}

- (void)forceHideColorSpectrum {
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) animateDown];
    [self.toolbarView didShowMonitorView:YES];
}

- (void)selectHistoryColor {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    [self exitMoveModeIfNeeded];
    
    [(WBToolMonitorView *)[self.view viewWithTag:kToolMonitorTag] enableEraser:NO];
    WBBaseElement *element = [[self currentPage] currentElement];
    if ([element isKindOfClass:[TextElement class]]) {
        TextElement *textElement = (TextElement *) element;
        [textElement updateWithColor:[[SettingManager sharedManager] getCurrentColorTab].tabColor];
    }
}

- (void)exitMoveModeIfNeeded {
    if ([[self currentPage] isMovable]) {
        if ([[[self currentPage] currentElement] isKindOfClass:[TextElement class]]
            && [[[[self currentPage] currentElement] contentView] isFirstResponder]) {
            // Text Element is keeping the keyboard
            // So don't exit the Move mode
        } else {
            [self stopToMove];
        }
    }
}

- (void)monitorClosed {
    [self forceHideColorSpectrum];
}

- (void)selectEraser:(BOOL)select {
    if (select) {
        [self.toolbarView selectCanvasMode:kEraserMode];
    } else {
        if ([[[self currentPage] currentElement] isKindOfClass:[TextElement class]]) {
            [self focusControlOnText];
        } else {
            [self focusControlOnCanvas];
        }
    }
}

- (void)colorPicked:(UIColor *)color {
    [self.toolbarView updateColor:color];
    WBBaseElement *element = [[self currentPage] currentElement];
    if ([element isKindOfClass:[TextElement class]]) {
        TextElement *textElement = (TextElement *) element;
        [textElement updateWithColor:color];
    }
}

- (void)opacityChanged:(float)opacity {
    [self.toolbarView updateAlpha:opacity];
}

- (void)pointSizeChanged:(float)pointSize {
    [self.toolbarView updatePointSize:pointSize];
}

- (void)fontChanged:(NSString *)fontName {
    WBBaseElement *element = [[self currentPage] currentElement];
    if ([element isKindOfClass:[TextElement class]]) {
        TextElement *textElement = (TextElement *) element;
        [textElement updateWithFontName:fontName];
    }
}

- (void)addMoreButtonTappedFrom:(UIView *)toolbar {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    float centerOfAddMoreButton = toolbar.frame.origin.x+toolbar.frame.size.width-kAddMoreCellHeight*1.5;
    float bottom = toolbar.frame.origin.y;
    CGPoint point = CGPointMake(centerOfAddMoreButton - 1, bottom);
    addMorePopoverView = [WBPopoverView showPopoverAtPoint:point inView:self.view withContentView:addMoreView delegate:self];    
    [self.toolbarView didShowAddMoreView:YES];
}

- (void)moveButtonTapped {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    [self forceHideColorSpectrum];
    
    if ([[self currentPage] isMovable]) {
        [self stopToMove];
    } else {
        [self startToMove];
    }
}

- (void)startToMove {
    [[self currentPage] startToMove];
    [self.toolbarView didActivatedMove:YES];
}

- (void)stopToMove {
    [[self currentPage] stopToMove];
    [self.toolbarView didActivatedMove:NO];
}

- (void)initBaseCanvasElement {
    [[self currentPage] initBaseCanvasElement];
    [self focusControlOnCanvas];
}

- (void)addCanvasFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    [self stopToMove];
}

- (void)addCameraFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
        cameraController.delegate = self;
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraController.allowsEditing = NO;
        self.addPhotoPopover = [[UIPopoverController alloc] initWithContentViewController:cameraController];
        CGRect showRect = CGRectMake(view.frame.origin.x-3,
                                     view.frame.origin.y+view.frame.size.height,
                                     view.frame.size.width,
                                     view.frame.size.height);
        [self.addPhotoPopover presentPopoverFromRect:showRect
                                              inView:self.view
                            permittedArrowDirections:UIPopoverArrowDirectionDown
                                            animated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No camera"
                                                            message:@"Your device does not have a camera"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)addPhotoFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    __block WBBoard *blockSelf = self;
    
    AGImagePickerController *photoPickerController = [[AGImagePickerController alloc] initWithDelegate:self];
    photoPickerController.didFailBlock = ^(NSError *error) {
        if (error == nil) {
            [blockSelf.addPhotoPopover dismissPopoverAnimated:NO];
            
        } else {
            // We need to wait for the view controller to appear first.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [blockSelf.addPhotoPopover dismissPopoverAnimated:NO];
            });
        }
    };
    photoPickerController.didFinishBlock = ^(NSArray *info) {
        [blockSelf.addPhotoPopover dismissPopoverAnimated:NO];

        if ([info count] > 0) {
            for (ALAsset *asset in info) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    float scale = (IS_IPAD ? 0.5 : 1);
                    UIImage *image = [UIImage imageWithCGImage:iref
                                                         scale:scale
                                                   orientation:UIImageOrientationRight];
                    CGRect imageRect = CGRectMake(self.view.frame.size.width/4,
                                                  self.view.frame.size.height/4,
                                                  self.view.frame.size.width/2,
                                                  self.view.frame.size.height/2);
                    ImageElement *imageElement = [[ImageElement alloc] initWithFrame:imageRect
                                                                               image:image];
                    if ([info count] > 1) {
                        [imageElement rotateTo:arc4random()*(M_PI_4/RAND_MAX)/4];
                    }
                    
                    [[self currentPage] addElement:imageElement];
                }
            }
            [self startToMove];
        }
    };
    
    // Show saved photos on top
    photoPickerController.shouldShowSavedPhotosOnTop = NO;
    photoPickerController.shouldChangeStatusBarStyle = NO;
    photoPickerController.maximumNumberOfPhotosToBeSelected = 3;
    
    self.addPhotoPopover = [[UIPopoverController alloc] initWithContentViewController:photoPickerController];
    CGRect showRect = CGRectMake(view.frame.origin.x-3,
                                 view.frame.origin.y+view.frame.size.height,
                                 view.frame.size.width,
                                 view.frame.size.height);
    [self.addPhotoPopover presentPopoverFromRect:showRect
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionDown
                                        animated:YES];

}

- (void)addTextFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    
    if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
        [[SettingManager sharedManager] setCurrentColorTab:0];
    }

    [[self currentPage] addText];
    [self focusControlOnText];
    [self startToMove];
}

- (void)addPasteFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    
    NSObject *itemFromClipboard = [WBUtils getThingsFromClipboard];
    if (itemFromClipboard) {
        if ([itemFromClipboard isKindOfClass:[NSString class]]) {
            NSString *text = (NSString *) itemFromClipboard;
            CGRect textRect = CGRectMake(self.view.frame.size.width/4,
                                         self.view.frame.size.height/4,
                                         self.view.frame.size.width/2,
                                         self.view.frame.size.height/2);
            TextElement *textElement = [[TextElement alloc] initWithFrame:textRect];
            [textElement setText:text];
            [[self currentPage] addElement:textElement];
            [self startToMove];
            
        } else if ([itemFromClipboard isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *) itemFromClipboard;
            CGRect imageRect = CGRectMake(self.view.frame.size.width/4,
                                          self.view.frame.size.height/4,
                                          self.view.frame.size.width/2,
                                          self.view.frame.size.height/2);
            ImageElement *imageElement = [[ImageElement alloc] initWithFrame:imageRect
                                                                       image:image];
            [imageElement rotateTo:arc4random()*(M_PI_4/RAND_MAX)/4];
            [[self currentPage] addElement:imageElement];
            [self startToMove];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty clipboard"
                                                            message:@"You have not copied anything, please try again"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)addBackgroundFrom:(UIView *)view {
    [addMorePopoverView dismiss];
    
    UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
    photoController.delegate = self;
    photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoController.allowsEditing = NO;
    self.addPhotoPopover = [[UIPopoverController alloc] initWithContentViewController:photoController];
    CGRect showRect = CGRectMake(view.frame.origin.x-3,
                                 view.frame.origin.y+view.frame.size.height,
                                 view.frame.size.width,
                                 view.frame.size.height);
    [self.addPhotoPopover presentPopoverFromRect:showRect
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionDown
                                        animated:YES];
}

- (void)focusControlOnCanvas {
    [self.toolbarView selectCanvasMode:kCanvasMode];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) setTextMode:NO];
}

- (void)focusControlOnText {
    [self.toolbarView selectCanvasMode:kTextMode];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) setTextMode:YES];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) scrollFontTableViewToFont:((TextElement *) [[self currentPage] currentElement]).myFontName];
}

- (void)animationCurlUpExitBoard {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, -1] context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:YES];
    [UIView setAnimationDuration:kWBSessionAnimationDuration];
    [UIView commitAnimations];
}

- (void)exitBoardWithResult:(BOOL)showResult {
    if (showResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [self exportBoardToUIImage];
            
            [self animationCurlUpExitBoard];
            
            if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoard:withResult:)]) {
                [self.delegate doneEditingBoard:self withResult:image];
            }
        });
    } else {
        [self animationCurlUpExitBoard];
        
        if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoard:withResult:)]) {
            [self.delegate doneEditingBoard:self withResult:nil];
        }
    }
}

#pragma mark - Animation Show/Dismiss board
- (void)showMeWithAnimationFromController:(UIViewController *)controller {
    [controller presentViewController:self animated:NO completion:NULL];
    
    [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, -1] context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:YES];
    [UIView setAnimationDuration:kWBSessionAnimationDuration];
    [UIView commitAnimations];
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.toolbarView.frame;
        frame.origin.y -= kbSize.height;
        self.toolbarView.frame = frame;
        
        frame = ((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]).frame;
        frame.origin.y -= kbSize.height;
        ((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]).frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.toolbarView.frame;
        frame.origin.y += kbSize.height;
        self.toolbarView.frame = frame;
        
        frame = ((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]).frame;
        frame.origin.y += kbSize.height;
        ((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]).frame = frame;
    }];
}

#pragma mark - UIImagePickerController Delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.addPhotoPopover dismissPopoverAnimated:NO];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (image) {
            CGRect imageRect = CGRectMake(self.view.frame.size.width/4,
                                          self.view.frame.size.height/4,
                                          self.view.frame.size.width/2,
                                          self.view.frame.size.height/2);
            ImageElement *imageElement = [[ImageElement alloc] initWithFrame:imageRect
                                                                       image:image];
            [[self currentPage] addElement:imageElement];
            [self startToMove];
        }
    } else {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (image) {
            [[self currentPage] addBackgroundElementWithImage:image];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.addPhotoPopover dismissPopoverAnimated:NO];
}

#pragma mark - AGImagePickerControllerDelegate methods
- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
         numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
              andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 4;
        else
            return 4;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 4;
        else
            return 4;
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : NO);
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : NO);
}

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    
    NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:[self.pages count]];
    for (WBPage *page in self.pages) {
        NSDictionary *pageDict = [page saveToData];
        [pageArray addObject:pageDict];
    }
    
    [dict setObject:pageArray forKey:@"board_pages"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
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
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Elements
- (void)elementRevived {
    [self.toolbarView didActivatedMove:NO];
}

- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden {
    if (hidden) {
        [self stopToMove];
        [self focusControlOnCanvas];
    } else {
        if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
            [[SettingManager sharedManager] setCurrentColorTab:0];
        }
        [self startToMove];
        [self focusControlOnText];
    }
}

#pragma mark - Import/Export Board Data
- (NSDictionary *)exportBoardData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    
    NSMutableDictionary *boardPages = [NSMutableDictionary new];
    for (WBPage *page in self.pages) {
        [boardPages setObject:[page saveToData] forKey:page.uid];
    }
    [dict setObject:boardPages forKey:@"board_pages"];
    
    return dict;
}

- (void)importBoardData:(NSDictionary *)data withBlock:(WBResultBlock)block {
    [GSSVProgressHUD showWithStatus:@"Loading..."];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.uid = [data objectForKey:@"board_uid"];
        self.name = [data objectForKey:@"board_name"];
        self.view.frame = CGRectFromString([data objectForKey:@"board_frame"]);
        
        // Remove all pages
        for (WBPage *existedPage in self.pages) {
            [existedPage removeFromSuperview];
        }
        [self.pages removeAllObjects];
        
        // Start to reconstruct all pages
        NSDictionary *boardPages = [data objectForKey:@"board_pages"];
        NSArray *pageKeys = [boardPages allKeys];
        pageKeys = [pageKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (int i = 0; i < [pageKeys count]; i++) {
            NSString *pageUid = [pageKeys objectAtIndex:i];
            NSDictionary *pageData = [boardPages objectForKey:pageUid];
            
            // Reconstruct this page
            [self importPageData:pageData withBlock:nil];
            
            [self initBaseCanvasElement];
        }
        [GSSVProgressHUD dismiss];
        
        if (block) { block(YES, nil); }
    });
}

- (void)importBoardHistoryData:(NSDictionary *)data boardUid:(NSString *)boardUid {
    // TODO: history add/remove/switch pages
}

- (void)importPageData:(NSDictionary *)pageData withBlock:(WBResultBlock)block {
    NSString *pageUid = [pageData objectForKey:@"page_uid"];
    WBPage *page = nil;
    for (WBPage *existedPage in self.pages) {
        if ([existedPage.uid isEqualToString:pageUid]) {
            page = existedPage;
            break;
        }
    }
    
    if (page == nil) {
        CGRect pageFrame = CGRectFromString([pageData objectForKey:@"page_frame"]);
        page = [[WBPage alloc] initWithFrame:pageFrame];
        [page setUid:pageUid];
        [page setPageDelegate:self];
        
        [self.pageHolderView addSubview:page];
        [self.pages addObject:page];
        [self setCurrentPageIndex:([self.pages count]-1)];
    }
    
    // Remove all elements
    for (WBBaseElement *existedElement in page.subviews) {
        [existedElement removeFromSuperview];
    }
    
    // Page is finally recreated, now we need to apply all history to this page
    NSDictionary *pageHistoryData = [pageData objectForKey:@"page_history"];
    NSArray *allKeys = [pageHistoryData allKeys];
    allKeys = [allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (int j = 0; j < [allKeys count]; j++) {
        NSString *historyUid = [allKeys objectAtIndex:j];
        NSDictionary *historyData = [pageHistoryData objectForKey:historyUid];
        [self importPageHistoryData:historyData pageUid:pageUid];
    }
    
    if (block) { block(YES, nil); }
}

- (void)importPageHistoryData:(NSDictionary *)historyData pageUid:(NSString *)pageUid {
    if (!pageUid) {
        pageUid = [historyData objectForKey:@"page_uid"];
    }
    
    WBPage *page = nil;
    for (WBPage *existedPage in self.pages) {
        if ([existedPage.uid isEqualToString:pageUid]) {
            page = existedPage;
            break;
        }
    }
    
    if (page) {
        NSString *historyType = [historyData objectForKey:@"history_type"];
        
        HistoryElement *history;
        WBBaseElement *historyElement;
        // History create element: now create it again
        if ([historyType isEqualToString:@"HistoryElementCreated"]) {
            history = [[HistoryElementCreated alloc] init];
            
        // History delete element: now delete it again
        } else if ([historyType isEqualToString:@"HistoryElementDeleted"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementDeleted alloc] init];
                [history setElement:historyElement];
            }
            
        // History draw on the canvas, now draw it again
        } else if ([historyType isEqualToString:@"HistoryElementCanvasDraw"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementCanvasDraw alloc] init];
                [history setElement:historyElement];
            }
            
        // History text changed: now change it again
        } else if ([historyType isEqualToString:@"HistoryElementTextChanged"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementTextChanged alloc] init];
                [history setElement:historyElement];
            }
        
        // History text font changed: now change it again
        } else if ([historyType isEqualToString:@"HistoryElementTextFontChanged"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementTextFontChanged alloc] init];
                [history setElement:historyElement];
            }
            
        // History text color changed: now change it again
        } else if ([historyType isEqualToString:@"HistoryElementTextColorChanged"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementTextColorChanged alloc] init];
                [history setElement:historyElement];
            }
            
        // History element transform: now transform it again
        } else if ([historyType isEqualToString:@"HistoryElementTransform"]) {
            NSString *elementUid = [historyData objectForKey:@"element_uid"];
            historyElement = [page elementByUid:elementUid];
            if (historyElement) {
                history = [[HistoryElementTransform alloc] init];
                [history setElement:historyElement];
            }
        }
        
        if (history) {
            [history loadFromData:historyData forPage:page];
            [[HistoryManager sharedManager] addAction:history forPage:page];
        }
    }
}

#pragma mark - Save/Load from Local Storage
- (void)saveBoardDataToLocalStorageWithName:(NSString *)boardName {
    NSString *folderPath = [WBUtils getBaseDocumentFolder];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"%@.hector", boardName]];
    NSDictionary *boardDict = [self exportBoardData];
	[boardDict writeToFile:filePath atomically:NO];
}

- (WBBoard *)loadBoardDataFromLocalStorageWithName:(NSString *)boardName {
    NSString *folderPath = [WBUtils getBaseDocumentFolder];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"%@.hector", boardName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *boardDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        WBBoard *board = [[WBBoard alloc] init];
        [board importBoardData:boardDict withBlock:^(BOOL succeed, NSError *error) {}];
        return board;
    }
    return nil;
}

+ (NSString *)mySecretId {
    return [SettingManager mySecretId];
}

+ (void)resetSecretId {
    [SettingManager resetSecretId];
}

- (void)dealloc {
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[HistoryManager sharedManager] clearHistoryPool];
    [[PaintingManager sharedManager] removeAllCallbacks];
    [self.pages removeAllObjects];
}

- (WBPage *)pageByUid:(NSString *)pageUid {
    WBPage *existedPage = nil;
    for (WBPage *page in self.pages) {
        if ([pageUid isEqualToString:pageUid]) {
            existedPage = page;
            break;
        }
    }
    return existedPage;
}

#pragma mark - Collaboration Back
- (void)didCreateCanvasElementWithUid:(NSString *)elementUid
                              pageUid:(NSString *)pageUid {
    [self.delegate didCreateCanvasElementWithUid:elementUid
                                         pageUid:pageUid
                                        boardUid:self.uid];
}

- (void)didCreateTextElementWithUid:(NSString *)elementUid
                            pageUid:(NSString *)pageUid
                          textFrame:(CGRect)textFrame
                               text:(NSString *)text
                          textColor:(UIColor *)textColor
                           textFont:(NSString *)textFont
                           textSize:(float)textSize {
    float red, green, blue, alpha;
    [textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    [self.delegate didCreateTextElementWithUid:elementUid
                                     textFrame:textFrame
                                          text:text
                                  textColorRed:red
                                textColorGreen:green
                                 textColorBlue:blue
                                textColorAlpha:alpha
                                      textFont:textFont
                                      textSize:textSize
                                       pageUid:pageUid
                                      boardUid:self.uid];
}

- (void)didApplyColorRed:(float)red
                   green:(float)green
                    blue:(float)blue
                   alpha:(float)alpha
              strokeSize:(float)strokeSize
              elementUid:(NSString *)elementUid
                 pageUid:(NSString *)pageUid {
    [self.delegate didApplyColorRed:red
                              green:green
                               blue:blue
                              alpha:alpha
                         strokeSize:strokeSize
                         elementUid:elementUid
                            pageUid:pageUid
                           boardUid:self.uid];
}

- (void)didRenderLineFromPoint:(CGPoint)start
                       toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer
                     isErasing:(BOOL)isErasing
                    elementUid:(NSString *)elementUid
                       pageUid:(NSString *)pageUid {
    [self.delegate didRenderLineFromPoint:start
                                  toPoint:end
                           toURBackBuffer:toURBackBuffer
                                isErasing:isErasing
                               elementUid:elementUid
                                  pageUid:pageUid
                                 boardUid:self.uid];
}

- (void)didChangeTextContent:(NSString *)text
                  elementUid:(NSString *)elementUid
                     pageUid:(NSString *)pageUid {
    [self.delegate didChangeTextContent:text
                             elementUid:elementUid
                                pageUid:pageUid
                               boardUid:self.uid];
}

- (void)didChangeTextFont:(NSString *)textFont
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid {
    [self.delegate didChangeTextFont:textFont
                          elementUid:elementUid
                             pageUid:pageUid
                            boardUid:self.uid];
}

- (void)didChangeTextSize:(float)textSize
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid {
    [self.delegate didChangeTextSize:textSize
                          elementUid:elementUid
                             pageUid:pageUid
                            boardUid:self.uid];
}

- (void)didChangeTextColor:(UIColor *)textColor
                elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    float red, green, blue, alpha;
    [textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    [self.delegate didChangeTextColorRed:red
                          textColorGreen:green
                           textColorBlue:blue
                          textColorAlpha:alpha
                              elementUid:elementUid
                                 pageUid:pageUid
                                boardUid:self.uid];
}

- (void)didMoveTo:(CGPoint)dest elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    [self.delegate didMoveTo:dest elementUid:elementUid pageUid:pageUid boardUid:self.uid];
}

- (void)didRotateTo:(float)rotation elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    [self.delegate didRotateTo:rotation elementUid:elementUid pageUid:pageUid boardUid:self.uid];
}

- (void)didScaleTo:(float)scale elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    [self.delegate didScaleTo:scale elementUid:elementUid pageUid:pageUid boardUid:self.uid];
}

- (void)didMoveTo:(CGPoint)dest pageUid:(NSString *)pageUid {
    [self.delegate didMoveTo:dest pageUid:pageUid boardUid:self.uid];
}

- (void)didScaleTo:(float)scale pageUid:(NSString *)pageUid {
    [self.delegate didScaleTo:scale pageUid:pageUid boardUid:self.uid];
}

- (void)didApplyFromTransform:(CGAffineTransform)from toTransform:(CGAffineTransform)to
                transformName:(NSString *)transformName
                   elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    [self.delegate didApplyFromTransform:from toTransform:to
                           transformName:transformName
                              elementUid:elementUid pageUid:pageUid boardUid:self.uid];
}

#pragma mark - Collaboration Forward
- (void)addNewPageWithUid:(NSString *)pageUid {
    WBPage *page = [[WBPage alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height)];
    [page setUid:pageUid];
    [page setPageDelegate:self];
    
    [self.pageHolderView addSubview:page];
    [self.pages addObject:page];
    [self setCurrentPageIndex:([self.pages count]-1)];
}

- (void)removeAllPages {
    [self.pages removeAllObjects];
    [[self.pageHolderView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)createCanvasElementWithUid:(NSString *)elementUid
                           pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page createCanvasElementWithUid:elementUid];
    }
}

- (void)createTextElementWithUid:(NSString *)elementUid
                         pageUid:(NSString *)pageUid
                       textFrame:(CGRect)textFrame
                            text:(NSString *)text
                    textColorRed:(float)red
                  textColorGreen:(float)green
                   textColorBlue:(float)blue
                  textColorAlpha:(float)alpha
                        textFont:(NSString *)textFont
                        textSize:(float)textSize {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        UIColor *textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [page createTextElementwithUid:elementUid
                             textFrame:textFrame
                                  text:text
                             textColor:textColor
                              textFont:textFont
                              textSize:textSize];
    }
}

- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize
           elementUid:(NSString *)elementUid
              pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page applyColorRed:red
                      green:green
                       blue:blue
                      alpha:alpha
                 strokeSize:strokeSize
                 elementUid:elementUid];
    }
}

- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing
                 elementUid:(NSString *)elementUid
                    pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page renderLineFromPoint:start
                          toPoint:end
                   toURBackBuffer:toURBackBuffer
                        isErasing:isErasing
                       elementUid:elementUid];
    }
}

- (void)changeTextContent:(NSString *)text
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page changeTextContent:text
                     elementUid:elementUid];
    }
}

- (void)changeTextFont:(NSString *)textFont
            elementUid:(NSString *)elementUid
               pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page changeTextFont:textFont
                  elementUid:elementUid];
    }
}

- (void)changeTextSize:(float)textSize elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page changeTextSize:textSize
                  elementUid:elementUid];
    }
}

- (void)changeTextColorRed:(float)red textColorGreen:(float)green
             textColorBlue:(float)blue textColorAlpha:(float)alpha
                elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        UIColor *textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [page changeTextColor:textColor
                   elementUid:elementUid];
    }
}

- (void)moveTo:(CGPoint)dest elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page moveTo:dest elementUid:elementUid];
    }
}

- (void)rotateTo:(float)rotation elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page rotateTo:rotation elementUid:elementUid];
    }
}

- (void)scaleTo:(float)scale elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page scaleTo:scale elementUid:elementUid];
    }
}

- (void)moveTo:(CGPoint)dest pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page moveTo:dest];
    }
}

- (void)scaleTo:(float)scale pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page scaleTo:scale];
    }
}

- (void)applyFromTransform:(CGAffineTransform)from toTransform:(CGAffineTransform)to
             transformName:(NSString *)transformName
                elementUid:(NSString *)elementUid pageUid:(NSString *)pageUid {
    WBPage *page = [self pageByUid:pageUid];
    if (page) {
        [page applyFromTransform:from toTransform:to transformName:transformName elementUid:elementUid];
    }
}

@end
