//
//  CPMessage.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPMessage.h"

@implementation CPMessage
@synthesize uid = _uid;
@synthesize sender = _sender;
@synthesize content = _messageContent;
@synthesize messageTime = _messageTime;
@synthesize createdDateInterval = _createdDateInterval;

- (NSString *) description {
    return [NSString stringWithFormat:@"User: %@ sent at time: %@", self.sender.username, [GSUtils stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.createdDateInterval]]];
}
@end
