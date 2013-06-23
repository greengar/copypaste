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
#import "BoardManager.h"
#import "HistoryManager.h"
#import "HistoryElement.h"
#import "SettingManager.h"
#import "GSButton.h"
#import "HistoryView.h"
#import "WBMenubarView.h"
#import "WBToolbarView.h"
#import "WBToolMonitorView.h"
#import "WBAddMoreSelectionView.h"
#import "WBMenuContentView.h"
#import "AGImagePickerController.h"
#import "AGIPCToolbarItem.h"
#import "HistoryElementCanvasDraw.h"
#import "MultiStrokePaintingCmd.h"

#define kToolBarItemWidth   (IS_IPAD ? 64 : 64)
#define kToolBarItemHeight  (IS_IPAD ? 64 : 64)

#define kHistoryViewTag     888
#define kToolMonitorTag     kHistoryViewTag+1
#define kAddMoreTag         kHistoryViewTag+2

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

@interface WBBoard () <WBPageDelegate, WBToolbarDelegate, WBToolMonitorDelegate, WBMenubarDelegate, WBAddMoreSelectionDelegate, WBMenuContentViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AGImagePickerControllerDelegate>
{
    BOOL isPageCurlAnimating;
    BOOL isPageCurled;
    float pageUpSpeed;
    float pageUpTime;
    BOOL wantToTurnToPreviousPage;
    WBMenuContentView *menuContentView;
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

// Designated initalizer - this method should always be called when creating a WBBoard
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"B_"];
        self.name = [NSString stringWithFormat:@"Whiteboard %@", [WBUtils getCurrentTime]];
        self.pages = [NSMutableArray new];
        
        [self initLayersWithFrame:self.view.frame]; // initializes self.menubarView
        [self addNewPage];
        
        [[SettingManager sharedManager] setCurrentColorTab:0];
        
        [self initPageCurlControl];
        
        int menuContentHeight = kMenuViewHeight+kOffsetForBouncing;
        WBMenubarView *menubar = self.menubarView;
        menuContentView = [[WBMenuContentView alloc] initWithFrame:CGRectMake(menubar.frame.origin.x, menubar.frame.origin.y+menubar.frame.size.height, menubar.frame.size.width*1.25, menuContentHeight)];
        [menuContentView setDelegate:self];
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

- (void)addMenuItem:(WBMenuItem *)item
{
    [menuContentView addMenuItem:item];
}

- (int)numOfPages {
    return [self.pages count];
}

#pragma mark - Tool/Control for Board
- (void)initLayersWithFrame:(CGRect)frame {
    // Page Holder
    self.pageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.pageHolderView.backgroundColor = [UIColor clearColor];
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
}

#pragma mark - Pages Handler
- (void)addNewPage {
    WBPage *page = [[WBPage alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height)];
    [page setPageDelegate:self];
    [page select];
    
    [self.pageHolderView addSubview:page];
    [self.pages addObject:page];
    [self setCurrentPageIndex:([self.pages count]-1)];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageOfBoard:dataUpdate:)]) {
        [self.delegate pageOfBoard:self dataUpdate:[page saveToDict]];
    }
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
    
    [page select];
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
- (void)initPageCurlControl {
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
    [((UIButton *) [self.exportControlView viewWithTag:kNextButtonTag]) setTitle:(([self currentPageIndex] < [self.pages count]-1) ? @"Next" : @"New")
                                                                        forState:UIControlStateNormal];
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
    [self forceHideMenu];
    [self forceHideHistory];
    [self forceHideColorSpectrum];
    [self forceHideAddMore];
    [[self menubarView] setHidden:YES];
    [[self toolbarView] setHidden:YES];
    [[self pageCurlButton] setHidden:YES];
}

#pragma mark - Export output data
- (UIImage *)exportBoardToUIImage {
    return [[self currentPage] exportPageToImage];
}

#pragma mark - Menu Bar Buttons
- (void)menuButtonTappedFrom:(UIView *)menubar
{
    // TODO: How did this work before?
    // I can't find any place in the code where `menuContentView` is removed from its superview.
    // TODO: inside animationDidStop:finished: of WBMenuContent, when the animation up is done
    // it is removed from its superview
    if (menuContentView.superview == nil)
    {
        // menuContentView is not visible at all
        [self.view addSubview:menuContentView];
        [menuContentView animateDown];
        
        [self forceHideHistory];
        
        [self.menubarView didShowMenuView:YES];
    }
    else
    {
        // menuContentView may be animating down; visible; or animating up
        [self forceHideMenu];
    }
}

- (void)forceHideMenu {
    [menuContentView animateUp];
    [self.menubarView didShowMenuView:NO];
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
    if (![self.view viewWithTag:kHistoryViewTag]) {
        int historyHeight = kHistoryViewHeight+kOffsetForBouncing;
        HistoryView *historyView = [[HistoryView alloc] initWithFrame:CGRectMake(menubar.frame.origin.x, menubar.frame.origin.y+menubar.frame.size.height, menubar.frame.size.width, historyHeight)];
        [historyView setTag:kHistoryViewTag];
        [historyView setCurrentPage:[self currentPage]];
        [self.view addSubview:historyView];
        [historyView animateDown];
        
        [self forceHideMenu];
        
        [[HistoryManager sharedManager] setDelegate:historyView];
        [self.menubarView didShowHistoryView:YES];
        
    } else {
        [self forceHideHistory];
    }
}

- (void)forceHideHistory {
    [((HistoryView *) [self.view viewWithTag:kHistoryViewTag]) animateUp];
    [self.menubarView didShowHistoryView:NO];
}

#pragma mark - Tool Bar Buttons
- (void)canvasButtonTappedFrom:(UIView *)toolbar {
    if ([[self currentPage] isLocked]) {
        [self forceUnlock];
    }
    
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
        
        [self forceHideAddMore];

        if ([[[self currentPage] selectedElementView] isKindOfClass:[TextElement class]]) {
            [toolMonitorView setTextMode:YES];
            [toolMonitorView setCurrentFont:((TextElement *) [[self currentPage] selectedElementView]).myFontName];
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
    if ([[self currentPage] isLocked]) {
        [self forceUnlock];
    }
    
    [(WBToolMonitorView *)[self.view viewWithTag:kToolMonitorTag] enableEraser:NO];
    WBBaseElement *element = [[self currentPage] selectedElementView];
    if ([element isKindOfClass:[TextElement class]]) {
        TextElement *textElement = (TextElement *) element;
        [textElement updateWithColor:[[SettingManager sharedManager] getCurrentColorTab].tabColor];
    }
}

- (void)monitorClosed {
    [self forceHideColorSpectrum];
}

- (void)selectEraser:(BOOL)select {
    if (select) {
        [self.toolbarView selectCanvasMode:kEraserMode];
    } else {
        if ([[[self currentPage] selectedElementView] isKindOfClass:[TextElement class]]) {
            [self.toolbarView selectCanvasMode:kTextMode];
        } else {
            [self.toolbarView selectCanvasMode:kCanvasMode];
        }
    }
}

- (void)colorPicked:(UIColor *)color {
    [self.toolbarView updateColor:color];
    WBBaseElement *element = [[self currentPage] selectedElementView];
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
    WBBaseElement *element = [[self currentPage] selectedElementView];
    if ([element isKindOfClass:[TextElement class]]) {
        TextElement *textElement = (TextElement *) element;
        [textElement updateWithFontName:fontName];
    }
}

- (void)addMoreButtonTappedFrom:(UIView *)toolbar {
    if ([[self currentPage] isLocked]) {
        [self forceUnlock];
    }
    
    if (![self.view viewWithTag:kAddMoreTag]) {
        int addMoreHeight = kAddMoreViewHeight+kOffsetForBouncing;
        WBAddMoreSelectionView *addMoreView = [[WBAddMoreSelectionView alloc] initWithFrame:CGRectMake(toolbar.frame.origin.x+toolbar.frame.size.width-kAddMoreCellHeight*3, toolbar.frame.origin.y-addMoreHeight, kAddMoreCellHeight*3, addMoreHeight)];
        [addMoreView setTag:kAddMoreTag];
        [addMoreView setDelegate:self];
        [self.view addSubview:addMoreView];
        [addMoreView animateUp];
        
        [self forceHideColorSpectrum];
        
        if ([[[self currentPage] selectedElementView] isKindOfClass:[TextElement class]]) {
            [addMoreView setIsCanvasMode:NO];
        } else {
            [addMoreView setIsCanvasMode:YES];
        }
        [self.toolbarView didShowAddMoreView:YES];
        
    } else {
        [self forceHideAddMore];
    }
}

- (void)forceHideAddMore {
    [((WBAddMoreSelectionView *) [self.view viewWithTag:kAddMoreTag]) animateDown];
    [self.toolbarView didShowAddMoreView:NO];
}

- (void)moveButtonTapped {
    [self forceHideColorSpectrum];
    [self forceHideAddMore];
    [self forceHideHistory];
    
    if ([[self currentPage] isLocked]) {
        [self forceUnlock];
    } else {
        [[self currentPage] setIsLocked:YES];
        [self.toolbarView didActivatedMove:YES];
    }
}

- (void)forceUnlock {
    [[self currentPage] setIsLocked:NO];
    [[self currentPage] focusOnTopElement];
    [self.toolbarView selectCanvasMode:kCanvasMode];
    [self.toolbarView didActivatedMove:NO];
}

- (void)addCanvasFrom:(UIView *)view {
    [[self currentPage] focusOnCanvas];
    [self.toolbarView didShowAddMoreView:NO];
    [self.toolbarView selectCanvasMode:kCanvasMode];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) setTextMode:NO];
}

- (void)addCameraFrom:(UIView *)view {
    [self.toolbarView didShowAddMoreView:NO];
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
}

- (void)addPhotoFrom:(UIView *)view {
    [self.toolbarView didShowAddMoreView:NO];
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
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    CGRect imageRect = CGRectMake(self.view.frame.size.width/4,
                                                  self.view.frame.size.height/4,
                                                  self.view.frame.size.width/2,
                                                  self.view.frame.size.height/2);
                    ImageElement *imageElement = [[ImageElement alloc] initWithFrame:imageRect
                                                                               image:image];
                    [imageElement rotateTo:arc4random()*(M_PI_4/RAND_MAX)/4];
                    [[self currentPage] addElement:imageElement];
                }
            }
            [[self currentPage] setIsLocked:YES];
            [self.toolbarView didActivatedMove:YES];
        }
    };
    
    // Show saved photos on top
    photoPickerController.shouldShowSavedPhotosOnTop = NO;
    photoPickerController.shouldChangeStatusBarStyle = NO;
    
    // Custom toolbar items
    UIBarButtonItem *selectAllBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:nil
                                                                        action:nil];
    UIBarButtonItem *flexibleBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];
    UIBarButtonItem *deselectAllBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];
    AGIPCToolbarItem *selectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:selectAllBtnItem
                                                                andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
                                                                    return YES;
                                                                }];
    AGIPCToolbarItem *flexible = [[AGIPCToolbarItem alloc] initWithBarButtonItem:flexibleBtnItem
                                                               andSelectionBlock:nil];
    
    AGIPCToolbarItem *deselectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:deselectAllBtnItem
                                                                  andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
                                                                      return NO;
                                                                  }];
    photoPickerController.toolbarItemsForManagingTheSelection = @[selectAll, flexible, flexible, deselectAll];
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
    // Back to first color, ignore using eraser color for text
    [[SettingManager sharedManager] setCurrentColorTab:0];
    
    [[self currentPage] focusOnText];
    [self.toolbarView didShowAddMoreView:NO];
    [self.toolbarView selectCanvasMode:kTextMode];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) setTextMode:YES];
    [((WBToolMonitorView *) [self.view viewWithTag:kToolMonitorTag]) scrollFontTableViewToFont:((TextElement *) [[self currentPage] selectedElementView]).myFontName];
}

- (void)addPasteFrom:(UIView *)view {
    [self.toolbarView didShowAddMoreView:NO];
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
            [[self currentPage] setIsLocked:YES];
            [self.toolbarView didActivatedMove:YES];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty clipboard" message:@"You have not copied anything, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)exitBoardWithResult:(BOOL)showResult {
    if (showResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HistoryManager sharedManager] clearHistoryPool];
            UIImage *image = [self exportBoardToUIImage];
            
            [self dismissViewControllerAnimated:NO completion:NULL];
            [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, -1] context:nil];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                                   forView:[UIApplication sharedApplication].keyWindow
                                     cache:YES];
            [UIView setAnimationDuration:kWBSessionAnimationDuration];
            [UIView commitAnimations];
            
            if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
                [self.delegate doneEditingBoardWithResult:image];
            }
        });
    } else {
        [self dismissViewControllerAnimated:NO completion:NULL];
        [UIView beginAnimations:[NSString stringWithFormat:kCurlUpAndDownAnimationKey, -1] context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                               forView:[UIApplication sharedApplication].keyWindow
                                 cache:YES];
        [UIView setAnimationDuration:kWBSessionAnimationDuration];
        [UIView commitAnimations];
        
        if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(doneEditingBoardWithResult:)]) {
            [self.delegate doneEditingBoardWithResult:nil];
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
    
    [[BoardManager sharedManager] createANewBoard:self];
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
    
    if (![[self currentPage] isLocked]) {
        [self addCanvasFrom:nil];
    }
    
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
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (image) {
        CGRect imageRect = CGRectMake(self.view.frame.size.width/4,
                                      self.view.frame.size.height/4,
                                      self.view.frame.size.width/2,
                                      self.view.frame.size.height/2);
        ImageElement *imageElement = [[ImageElement alloc] initWithFrame:imageRect
                                                                   image:image];
        [imageElement rotateTo:arc4random()*(M_PI_4/RAND_MAX)/4];
        [[self currentPage] addElement:imageElement];
        [[self currentPage] setIsLocked:YES];
        [self.toolbarView didActivatedMove:YES];
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

#pragma mark - Collaboration
- (void)pageHistoryCreated:(HistoryAction *)history {
    NSMutableString *historyURL = [NSMutableString new];
    [historyURL appendString:@"board_pages"];
    [historyURL appendFormat:@"/%@", [[self currentPage] uid]];
    [historyURL appendFormat:@"/page_history/%@", [history uid]];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageOfBoard:addNewHistory:atURL:)]) {
        [self.delegate pageOfBoard:self addNewHistory:[history backupToData] atURL:historyURL];
    }
}

- (NSDictionary *)exportBoardMetadata {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    return dict;
}

- (NSDictionary *)exportBoardData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"board_uid"];
    [dict setObject:self.name forKey:@"board_name"];
    [dict setObject:NSStringFromCGRect(self.view.frame) forKey:@"board_frame"];
    
    NSMutableDictionary *boardPages = [NSMutableDictionary new];
    for (WBPage *page in self.pages) {
        [boardPages setObject:[page saveToDict] forKey:page.uid];
    }
    [dict setObject:boardPages forKey:@"board_pages"];
    
    return dict;
}

- (void)updateWithDataForBoard:(NSDictionary *)data {
    self.uid = [data objectForKey:@"board_uid"];
    self.name = [data objectForKey:@"board_name"];
    self.view.frame = CGRectFromString([data objectForKey:@"board_frame"]);
    
    NSDictionary *boardPages = [data objectForKey:@"board_pages"];
    for (NSString *pageUid in boardPages) {
        NSDictionary *pageData = [boardPages objectForKey:pageUid];
        CGRect pageFrame = CGRectFromString([pageData objectForKey:@"page_frame"]);
        WBPage *page = [[WBPage alloc] initWithFrame:pageFrame];
        [page setUid:pageUid];
        [page setPageDelegate:self];
        [page select];
        
        [self.pageHolderView addSubview:page];
        [self.pages addObject:page];
        [self setCurrentPageIndex:([self.pages count]-1)];
        
        NSDictionary *pageHistoryData = [pageData objectForKey:@"page_history"];
        for (NSString *historyUid in pageHistoryData) {
            NSDictionary *historyData = [pageHistoryData objectForKey:historyUid];
            NSString *historyType = [historyData objectForKey:@"history_type"];
            if ([historyType isEqualToString:@"HistoryElementCreate"]) {

            } else if ([historyType isEqualToString:@"HistoryElementCanvasDraw"]) {
                HistoryElementCanvasDraw *history = [[HistoryElementCanvasDraw alloc] init];
                [history setElement:[page selectedElementView]];
                [history setUid:historyUid];
                [history setName:[historyData objectForKey:@"history_name"]];
                [history setDate:[WBUtils dateFromString:[historyData objectForKey:@"history_date"]]];
                NSDictionary *paintingCmdData = [historyData objectForKey:@"history_painting"];
                
                NSString *paintingType = [paintingCmdData objectForKey:@"paint_cmd_type"];
                if ([paintingType isEqualToString:@"MultiStrokePaintingCmd"]) {
                    MultiStrokePaintingCmd *paintCmd = [[MultiStrokePaintingCmd alloc] init];
                    [paintCmd setUid:[paintingCmdData objectForKey:@"paint_cmd_uid"]];
                    [paintCmd setLayerIndex:[[paintingCmdData objectForKey:@"paint_cmd_layer"] intValue]];
                    [paintCmd setDrawingView:((MainPaintingView *) [[page selectedElementView] contentView])];
                    
                    NSDictionary *multiStrokesData = [paintingCmdData objectForKey:@"paint_multi_stroke_array"];
                    for (NSString *singlePaintUid in multiStrokesData) {
                        NSDictionary *singlePaintCmdData = [multiStrokesData objectForKey:singlePaintUid];
                        StrokePaintingCmd *singlePaintCmd = [[StrokePaintingCmd alloc] init];
                        [singlePaintCmd setUid:singlePaintUid];
                        [singlePaintCmd setLayerIndex:[[singlePaintCmdData objectForKey:@"paint_cmd_layer"] intValue]];
                        [singlePaintCmd pointSizeWithSize:[[singlePaintCmdData objectForKey:@"paint_stroke_point_size"] floatValue]];
                        CGRect colorRect = CGRectFromString([singlePaintCmdData objectForKey:@"paint_stroke_color"]);
                        [singlePaintCmd colorWithRed:colorRect.origin.x green:colorRect.origin.y blue:colorRect.size.width alpha:colorRect.size.height];
                        CGPoint start = CGPointFromString([singlePaintCmdData objectForKey:@"paint_stroke_start"]);
                        CGPoint end = CGPointFromString([singlePaintCmdData objectForKey:@"paint_stroke_end"]);
                        [singlePaintCmd strokeFromPoint:start toPoint:end];
                        [singlePaintCmd setDrawingView:((MainPaintingView *) [[page selectedElementView] contentView])];
                        
                        [paintCmd.strokeArray addObject:singlePaintCmd];
                    }
                    [history setPaintingCommand:paintCmd];
                }
                [history setActive:[[historyData objectForKey:@"history_active"] boolValue]];
                
                [[HistoryManager sharedManager] addAction:history forPage:page];
            }
        }
    }
}

- (void)updateWithDataForPage:(NSDictionary *)data {
    
}

- (void)updateWithDataForElement:(NSDictionary *)data {
    
}
@end
