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
- (void)board:(WBBoard *)board dataUpdate:(NSDictionary *)data;
- (void)pageOfBoard:(WBBoard *)board dataUpdate:(NSDictionary *)data;
- (void)pageOfBoard:(WBBoard *)board addNewHistory:(NSDictionary *)data atURL:(NSString *)URLString;
- (void)pageOfBoard:(WBBoard *)board updateHistoryCanvasDraw:(NSDictionary *)data atURL:(NSString *)URLString;
- (void)elementOfBoard:(WBBoard *)board dataUpdate:(NSDictionary *)data;
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

- (NSDictionary *)saveToDict;

- (void)updateWithDataForBoard:(NSDictionary *)data withBlock:(WBResultBlock)block;
- (void)updateWithHistoryDataForBoard:(NSDictionary *)data;
- (void)updateWithNewHistoryDataForBoard:(NSDictionary *)data;

- (void)updateWithDataForPage:(NSDictionary *)data pageUid:(NSString *)pageUid;
- (void)updateWithNewHistoryDataForPage:(NSDictionary *)data pageUid:(NSString *)pageUid;
- (void)updateWithNewHistoryElementCanvasDrawDataForPage:(NSDictionary *)data pageUid:(NSString *)pageUid;

- (NSDictionary *)exportBoardMetadata;
- (NSDictionary *)exportBoardData;
- (NSDictionary *)exportHistoryForBoard;
- (NSDictionary *)exportNewHistoryActionForBoard;

- (NSDictionary *)exportPageMetadata;
- (NSDictionary *)exportPageData;
- (NSDictionary *)exportHistoryForPage;
- (NSDictionary *)exportNewHistoryActionForPage;

- (NSDictionary *)exportElementMetadata;
- (NSDictionary *)exportElementData;
- (NSDictionary *)exportHistoryForElement;
- (NSDictionary *)exportNewHistoryActionForElement;

@property (nonatomic, strong) NSString              *uid;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) UIImage               *previewImage;
@property (nonatomic, strong) NSMutableArray        *tags;
@property (nonatomic, assign) id<WBBoardDelegate>   delegate;

- (void)addMenuItem:(WBMenuItem *)item;
- (void)doneEditing;

@end
