//
//  GSRoom.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSRoom.h"
#import "GSSession.h"
#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "GSSVProgressHUD.h"

@interface GSRoom()
@property (nonatomic, strong) NSString *firebaseUid;
@end

@implementation GSRoom
@synthesize firebaseUid = _firebaseUid;
@synthesize name = _name;
@synthesize ownerId = _ownerId;
@synthesize isPrivate = _isPrivate;
@synthesize codeToEnter = _codeToEnter;
@synthesize sharedEmails = _sharedEmails;
@synthesize data = _data;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize autoUpload = _autoUpload;
@synthesize delegate = _delegate;
@synthesize isListening = _isListening;

- (id)init {
    return [self initWithName:@"Untitle Room"
                      ownerId:[[GSSession currentUser] uid]
                    isPrivate:YES
                  codeToEnter:nil
                 sharedEmails:nil];
}

- (id)initWithPFObject:(PFObject *)object {
    if (self = [super initWithPFObject:object]) {
        self.name = [object objectForKey:@"name"];
        self.ownerId = [object objectForKey:@"owner_id"];
        self.isPrivate = [[object objectForKey:@"private"] boolValue];
        self.codeToEnter = [object objectForKey:@"code"];
        self.sharedEmails = [object objectForKey:@"shared_emails"];
        self.firebaseUid = [object objectForKey:@"uid"];
        self.data = [NSMutableDictionary new];
    }
    return self;
}

- (void)loadWithPFObject:(PFObject *)object {
    [super loadWithPFObject:object];
    self.name = [object objectForKey:@"name"];
    self.ownerId = [object objectForKey:@"owner_id"];
    self.isPrivate = [[object objectForKey:@"private"] boolValue];
    self.codeToEnter = [object objectForKey:@"code"];
    self.sharedEmails = [object objectForKey:@"shared_emails"];
    self.firebaseUid = [object objectForKey:@"uid"];
    self.data = [NSMutableDictionary new];
}

- (id)initWithName:(NSString *)name
           ownerId:(NSString *)ownerId
         isPrivate:(BOOL)isPrivate
       codeToEnter:(NSString *)codeToEnter
      sharedEmails:(NSArray *)sharedEmails {
    if (self = [super init]) {
        self.firebaseUid = [GSUtils generateUniqueIdWithPrefix:@"R_"];
        self.name = name ? name : @"Untitle Room";
        self.ownerId = ownerId ? ownerId : [[GSSession currentUser] uid];
        self.isPrivate = isPrivate;
        self.codeToEnter = codeToEnter;
        self.data = [NSMutableDictionary new];
        
        NSMutableArray *emails = [NSMutableArray arrayWithObjects:[[GSSession currentUser] email], nil];
        if (sharedEmails) {
            [emails addObjectsFromArray:sharedEmails];
        }
        self.sharedEmails = emails;
        
        [self setObject:self.firebaseUid forKey:@"uid"];
        [self setObject:self.name forKey:@"name"];
        [self setObject:self.ownerId forKey:@"owner_id"];
        [self setObject:[NSNumber numberWithBool:self.isPrivate] forKey:@"private"];
        [self setObject:self.codeToEnter forKey:@"code"];
        [self setObject:self.sharedEmails forKey:@"shared_emails"];
    }
    return self;
}

- (void)saveInBackground {
    if (self.codeToEnter) {
        PFQuery *query = [PFQuery queryWithClassName:[self classname]];
        [query whereKey:@"code" equalTo:self.codeToEnter];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]) {
                return;
            } else {
                [super saveInBackground];
            }
        }];
    } else {
        [super saveInBackground];
    }
    
    [self saveInBackground];
}

- (void)saveInBackgroundWithBlock:(GSResultBlock)block {
    if (self.codeToEnter) {
        PFQuery *query = [PFQuery queryWithClassName:[self classname]];
        [query whereKey:@"code" equalTo:self.codeToEnter];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]) {
                NSMutableDictionary *details = [NSMutableDictionary new];
                [details setValue:@"room code is existed, please select another code"
                           forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Existed Room Code"
                                                     code:404
                                                 userInfo:details];
                block(NO, error);
            } else {
                [super saveInBackgroundWithBlock:block];
            }
        }];
    } else {
        [super saveInBackgroundWithBlock:block];
    }
    
    [self saveDataInBackground];
}

- (void)saveDataInBackground {
    if (self.data) {
        [[GSSession activeSession] sendRoomData:self];
    }
}

- (void)setData:(NSMutableDictionary *)data {
    _data = data;
    
    if (self.autoUpload) {
        [self saveDataInBackground];
    }
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(dataDidChanged:)]) {
        [self.delegate dataDidChanged:self];
    }
}

- (void)loadDataWithBlock:(GSResultBlock)block {
    [GSSVProgressHUD showWithStatus:@"Loading..."];
    [[GSSession activeSession] registerRoomDataChanged:self
                                                  type:GSEventTypeValue
                                             withBlock:^(NSDictionary *data, NSError *error) {
        if (data) {
            [self setData:(NSMutableDictionary *)data];
            if (block) { block(YES, nil); }
        } else {
            if (block) { block(NO, nil); }
        }
        [GSSVProgressHUD dismiss];
        [[GSSession activeSession] unregisterRoomDataChanged:self];
    }];
}

- (NSString *)uid {
    return self.firebaseUid;
}

- (NSString *)classname {
    return @"Room";
}

+ (NSString *)classname {
    return @"Room";
}

@end
