//
//  CollaborativeViewController.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSSession.h"

@interface CollaborativeViewController : UIViewController <GSSessionDelegate> {
    IBOutlet UILabel  *logInLabel;
    IBOutlet UIButton *authenticationButton;
    IBOutlet UIButton *createRoomButton;
    IBOutlet UIButton *getPublicRoomButton;
    IBOutlet UIButton *getRoomByIdButton;
    IBOutlet UIButton *getUserByEmailButton;
}

- (IBAction)authenticate;
- (IBAction)createRoom;
- (IBAction)getAllPublicRoom;
- (IBAction)getRoomShareWithMe;
- (IBAction)getRoomById;
- (IBAction)getUserByEmail;

@end
