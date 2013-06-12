//
//  GSRoom.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSObject.h"

@interface GSRoom : GSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic)         BOOL isPrivate;
@property (nonatomic, strong) NSString *codeToEnter;
@property (nonatomic, strong) NSArray *sharedEmails;

- (id)initWithName:(NSString *)name
           ownerId:(NSString *)ownerId
         isPrivate:(BOOL)isPrivate
       codeToEnter:(NSString *)codeToEnter
      sharedEmails:(NSArray *)sharedEmails;
    
@end
