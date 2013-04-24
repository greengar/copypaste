//
//  CPMessage.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSSUser.h"
#import "GSSUtils.h"

@interface CPMessage : NSObject

@property (nonatomic) GSSUser *sender;
@property (nonatomic) NSObject *messageContent;
@property (nonatomic) NSTimeInterval createdDateInterval;

@end
