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
        
        PFFile *thumbnailFile = [object objectForKey:@"thumbnail"];
        if (thumbnailFile) {
            [self cacheThumbnailFromFile:thumbnailFile];
        }
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
    
    PFFile *thumbnailFile = [object objectForKey:@"thumbnail"];
    if (thumbnailFile) {
        [self cacheThumbnailFromFile:thumbnailFile];
    }
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

- (void)cacheThumbnailFromFile:(PFFile *)thumbnailFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.thumbnailImage = [UIImage imageWithData:[thumbnailFile getData]];
    });
}


- (void)saveInBackground {
    if (self.codeToEnter) {
        PFQuery *query = [PFQuery queryWithClassName:[self classname]];
        [query whereKey:@"code" equalTo:self.codeToEnter];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]) {
                return;
            } else {
                [self saveThumbnailInBackground];
                [super saveInBackground];
            }
        }];
    } else {
        [self saveThumbnailInBackground];
        [super saveInBackground];
    }
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
                if (block) { block(NO, error); }
            } else {
                [self saveThumbnailInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
                    [super saveInBackgroundWithBlock:block];
                }];
            }
        }];
    } else {
        [self saveThumbnailInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
            [super saveInBackgroundWithBlock:block];
        }];
    }
}

- (void)saveThumbnailInBackground {
    if (self.thumbnailImage) {
        NSData *imageData = UIImagePNGRepresentation(self.thumbnailImage);
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", self.uid] data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self setObject:imageFile forKey:@"thumbnail"];
                [super saveInBackground];
            }
        }];
    }
}

- (void)saveThumbnailInBackgroundWithBlock:(GSResultBlock)block {
    if (self.thumbnailImage) {
        NSData *imageData = UIImagePNGRepresentation(self.thumbnailImage);
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", self.uid] data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self setObject:imageFile forKey:@"thumbnail"];
                if (block) { block(succeeded, error); }
            }
        }];
    }
    if (block) { block(NO, nil); }
}

- (void)deleteInBackground {
    [super deleteInBackground];
    [[GSSession activeSession] removeRoomData:self];
}

- (void)deleteInBackgroundWithBlock:(GSResultBlock)block {
    [super deleteInBackgroundWithBlock:block];
    [[GSSession activeSession] removeRoomData:self];
}

- (void)setData:(NSMutableDictionary *)data {
    _data = data;
    
    if (self.autoUpload) {
        [self saveInBackground];
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

- (void)setName:(NSString *)name {
    _name = name;
    [self setObject:name forKey:@"name"];
}

- (void)setOwnerId:(NSString *)ownerId {
    _ownerId = ownerId;
    [self setObject:ownerId forKey:@"owner_id"];
}

- (void)setIsPrivate:(BOOL)isPrivate {
    _isPrivate = isPrivate;
    [self setObject:[NSNumber numberWithBool:isPrivate] forKey:@"private"];
}

- (void)setCodeToEnter:(NSString *)codeToEnter {
    _codeToEnter = codeToEnter;
    [self setObject:codeToEnter forKey:@"code"];
}

- (void)setSharedEmails:(NSArray *)sharedEmails {
    _sharedEmails = sharedEmails;
    [self setObject:sharedEmails forKey:@"shared_emails"];
}

- (void)setFirebaseUid:(NSString *)firebaseUid {
    _firebaseUid = firebaseUid;
    [self setObject:firebaseUid forKey:@"uid"];
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
