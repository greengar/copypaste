//
//  CPMessage.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Smartboard/Smartboard.h>

@interface CPMessage : NSObject

@property (nonatomic) GSUser *sender;
@property (nonatomic) NSObject *messageContent;
@property (nonatomic) NSTimeInterval createdDateInterval;

@end
