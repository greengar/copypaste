//
//  SDBoard.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"
#import "WBPage.h"
#import "WBBaseElement.h"

@interface WBBoard : UIViewController <SDPageDelegate, WBBaseViewDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;
- (void)setBackgroundImage:(UIImage *)image;
- (int)numOfPages;

- (NSMutableDictionary *)saveToDict;
+ (WBBoard *)loadFromDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) id<WBBoardDelegate> delegate;

@end
