//
//  CPUser.h
//  copypaste
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSUser.h"

@interface CPUser : GSSUser
@property (nonatomic) int numOfCopyFromMe;
@property (nonatomic) int numOfPasteToMe;
@end
