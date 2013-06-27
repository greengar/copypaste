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

@class WBBoard;
@protocol WBBoardDelegate
@optional
- (NSString *)facebookId;
- (void)doneEditingBoardWithResult:(UIImage *)image;
- (void)pageOfBoard:(WBBoard *)board dataUpdate:(NSMutableDictionary *)data atURL:(NSString *)URLString;
- (void)pageOfBoard:(WBBoard *)board addNewHistory:(NSMutableDictionary *)data atURL:(NSString *)URLString;
- (void)pageOfBoard:(WBBoard *)board updateHistoryCanvasDraw:(NSMutableDictionary *)data atURL:(NSString *)URLString;
- (void)pageOfBoard:(WBBoard *)board saveAtURL:(NSString *)URLString;
- (void)pageOfBoard:(WBBoard *)board saveHistoryCanvasDrawAtURL:(NSString *)URLString;
@end

@interface WBBoard : UIViewController

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
 Start to listen to any update to the current page
 */
- (void)startListeningToPageUpdate;

/*
 Reconstruct the board with the data dictionary
 @param data NSDictionary: data dictionary
 @param block WBResultBlock: result of the reconstruct process
 */
- (void)updateWithDataForBoard:(NSDictionary *)data withBlock:(WBResultBlock)block;

/*
 Reconstruct the board with the history data dictionary
 @param data NSDictionary: history data dictionary
 @param pageUid NSString: uid of the board which this history belongs to
 */
- (void)updateWithNewHistoryDataForBoard:(NSDictionary *)data boardUid:(NSString *)boardUid;

/*
 Reconstruct the page with the data dictionary
 @param data NSDictionary: data dictionary
 @param block WBResultBlock: result of the reconstruct process
 */
- (void)updateWithDataForPage:(NSDictionary *)data withBlock:(WBResultBlock)block;

/*
 Reconstruct the page with the history data dictionary
 @param data NSDictionary: history data dictionary
 @param pageUid NSString: uid of the page which this history belongs to
 */
- (void)updateWithNewHistoryDataForPage:(NSDictionary *)data pageUid:(NSString *)pageUid;

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

@property (nonatomic, strong) NSString              *uid;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) UIImage               *previewImage;
@property (nonatomic, strong) NSMutableArray        *tags;
@property (nonatomic, assign) id<WBBoardDelegate>   delegate;

- (void)addMenuItem:(WBMenuItem *)item;
- (void)doneEditing;

@end
