//
//  GSRoom.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSObject.h"
#import "GSUtils.h"

@class GSRoom;
@protocol GSRoomDelegate
- (void)dataDidChanged:(GSRoom *)room;
@end

@interface GSRoom : GSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic)         BOOL isPrivate;
@property (nonatomic, strong) NSString *codeToEnter;
@property (nonatomic, strong) NSArray *sharedEmails;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic)         BOOL autoUpload;
@property (nonatomic)         BOOL isListening;
@property (nonatomic, assign) id<GSRoomDelegate> delegate;

- (id)initWithName:(NSString *)name
           ownerId:(NSString *)ownerId
         isPrivate:(BOOL)isPrivate
       codeToEnter:(NSString *)codeToEnter
      sharedEmails:(NSArray *)sharedEmails;

- (void)saveDataInBackground;
- (void)loadDataWithBlock:(GSResultBlock)block;

@end
