//
//  CPUser.h
//  copypaste
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Smartboard/Smartboard.h>

@interface CPUser : GSUser
@property (nonatomic) int numOfUnreadMessage;
@property (nonatomic) int priority;
@property (nonatomic) int numOfCopyFromMe;
@property (nonatomic) int numOfPasteToMe;
@end
