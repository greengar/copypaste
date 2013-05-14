//
//  CPUser.m
//  copypaste
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPUser.h"

@implementation CPUser
@synthesize numOfUnreadMessage = _numOfUnreadMessage;
@synthesize priority = _priority;
@synthesize numOfCopyFromMe = _numOfCopyFromMe;
@synthesize numOfPasteToMe = _numOfPasteToMe;

- (void)setNumOfCopyFromMe:(int)numOfCopyFromMe {
    _numOfCopyFromMe = numOfCopyFromMe;
    _priority += numOfCopyFromMe;
}

- (void)setNumOfPasteToMe:(int)numOfPasteToMe {
    _numOfPasteToMe = numOfPasteToMe;
    _priority += numOfPasteToMe;
}

- (void)setIsOnline:(BOOL)isOnline {
    [super setIsOnline:isOnline];
    if (self.isOnline) {
        _priority += 1;
    }
}
@end
