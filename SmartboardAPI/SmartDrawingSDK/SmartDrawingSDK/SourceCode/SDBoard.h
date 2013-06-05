//
//  SDBoard.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDUtils.h"
#import "SDPage.h"
#import "SDBaseElement.h"

@interface SDBoard : UIViewController <SDPageDelegate, SDBaseViewDelegate>

- (void)setBackgroundImage:(UIImage *)image;
- (int)numOfPages;

- (NSDictionary *)saveToDict;
+ (SDBoard *)loadFromDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) id<SDBoardDelegate> delegate;

@end
