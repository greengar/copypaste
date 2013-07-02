//
//  CPMessage.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Smartboard/Smartboard.h>
#import "CPUser.h"

@interface CPMessage : NSObject

@property (nonatomic) NSString *uid;
@property (nonatomic) CPUser *sender;
@property (nonatomic) NSObject *content;
@property (nonatomic) NSString *messageTime;
@property (nonatomic) NSTimeInterval createdDateInterval;

@end
