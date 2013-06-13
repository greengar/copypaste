//
//  RoomDataViewController.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/12/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSRoom.h"

@interface RoomDataViewController : UIViewController <GSRoomDelegate>

@property (nonatomic, strong) GSRoom *room;

@end
