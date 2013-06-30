//
//  WBBoard.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"
#import "WBMenuItem.h"

@interface WBBoard : UIViewController

/*
 Init the board with a delegate callback
 The purpose is to receive board update notification via callback
 @param delegate id<WBBoardDelegate>: the delegate that implement the WBBoardDelegate protocol
 */
- (id)initWithDelegate:(id<WBBoardDelegate>)delegate;

/*
 Show the board with default animation
 Recommend to call this instead of pushViewController
 @param controller UIViewController: the root view controller to push the board
 */
- (void)showMeWithAnimationFromController:(UIViewController *)controller;

/*
 Return the number of pages in the current board
 @result Return int: number of pages
 */
- (int)numOfPages;

/*
 Lock the board, user will not be able to modify the board
 */
- (void)lockBoard;

/*
 Reconstruct the board with the data dictionary
 @param data NSDictionary: data dictionary
 @param block WBResultBlock: result of the reconstruct process
 */
- (void)importBoardData:(NSDictionary *)data withBlock:(WBResultBlock)block;

/*
 Reconstruct the board with the history data dictionary
 @param data NSDictionary: history data dictionary
 @param pageUid NSString: uid of the board which this history belongs to
 */
- (void)importBoardHistoryData:(NSDictionary *)data boardUid:(NSString *)boardUid;

/*
 Reconstruct the page with the data dictionary
 @param data NSDictionary: data dictionary
 @param block WBResultBlock: result of the reconstruct process
 */
- (void)importPageData:(NSDictionary *)data withBlock:(WBResultBlock)block;

/*
 Reconstruct the page with the history data dictionary
 @param data NSDictionary: history data dictionary
 @param pageUid NSString: uid of the page which this history belongs to
 */
- (void)importPageHistoryData:(NSDictionary *)data pageUid:(NSString *)pageUid;

/*
 Export data of the whole board
 @result Return NSDictionary: the board data dictionary
 */
- (NSDictionary *)exportBoardData;

/*
 Save board data to local storage with name
 @param boardName NSString: the name of the board to save
 */
- (void)saveBoardDataToLocalStorageWithName:(NSString *)boardName;

/*
 Load board data back from local storage with name
 @param boardName NSString: the name of the board to load
 @result Return WBBoard: the board from the storage, will be nil if not found
 */
- (WBBoard *)loadBoardDataFromLocalStorageWithName:(NSString *)boardName;

/*
 My Secret Id
 @result Return NSString: a secret id for your devices
 */
+ (NSString *)mySecretId;

/*
 Reset the current Secret Id
 */
+ (void)resetSecretId;

@property (nonatomic, strong) NSString              *uid;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) UIImage               *previewImage;
@property (nonatomic, strong) NSMutableArray        *tags;
@property (nonatomic, assign) id<WBBoardDelegate>   delegate;

- (void)addMenuItem:(WBMenuItem *)item;
- (void)doneEditing;

#pragma mark - Collaboration
- (void)addNewPageWithUid:(NSString *)pageUid;
- (void)addNewCanvas;
- (void)removeAllPages;
- (void)createCanvasElementWithUid:(NSString *)elementUid
                           pageUid:(NSString *)pageUid;
- (void)createTextElementWithUid:(NSString *)elementUid
                         pageUid:(NSString *)pageUid
                       textFrame:(CGRect)textFrame
                            text:(NSString *)text
                    textColorRed:(float)red
                  textColorGreen:(float)green
                   textColorBlue:(float)blue
                  textColorAlpha:(float)alpha
                        textFont:(NSString *)textFont
                        textSize:(float)textSize;
- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize
           elementUid:(NSString *)elementUid
              pageUid:(NSString *)pageUid;
- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing
             updateBoundary:(CGRect)boundingRect
                 elementUid:(NSString *)elementUid
                    pageUid:(NSString *)pageUid;
- (void)changeTextContent:(NSString *)text
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid;
- (void)changeTextFont:(NSString *)textFont
            elementUid:(NSString *)elementUid
               pageUid:(NSString *)pageUid;
- (void)changeTextSize:(float)textSize
            elementUid:(NSString *)elementUid
               pageUid:(NSString *)pageUid;
- (void)changeTextColorRed:(float)red
            textColorGreen:(float)green
             textColorBlue:(float)blue
            textColorAlpha:(float)alpha
                elementUid:(NSString *)elementUid
                   pageUid:(NSString *)pageUid;
- (void)moveTo:(CGPoint)dest
    elementUid:(NSString *)elementUid
       pageUid:(NSString *)pageUid;
- (void)rotateTo:(float)rotation
      elementUid:(NSString *)elementUid
         pageUid:(NSString *)pageUid;
- (void)scaleTo:(float)scale
     elementUid:(NSString *)elementUid
        pageUid:(NSString *)pageUid;
- (void)applyFromTransform:(CGAffineTransform)from
               toTransform:(CGAffineTransform)to
             transformName:(NSString *)transformName
                elementUid:(NSString *)elementUid
                   pageUid:(NSString *)pageUid;

@end
