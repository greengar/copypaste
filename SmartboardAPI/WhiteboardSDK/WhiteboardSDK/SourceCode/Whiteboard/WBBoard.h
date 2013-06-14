//
//  WBBoard.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"
#import "WBPage.h"

@interface WBBoard : UIViewController <WBPageDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;

- (void)showMeWithAnimationFromController:(UIViewController *)controller;

- (int)numOfPages;

- (WBPage *)currentPage;
- (WBPage *)pageAtIndex:(int)index;

- (NSDictionary *)saveToDict;
+ (WBBoard *)loadFromDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) id<WBBoardDelegate> delegate;

@end
