//
//  WBMenuContentView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/21/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBMenuItem.h"

#define MENU_ARRAY @[@"Exit", @"Saving", @"Sharing", @"Delete Page", @"Credits", @"Help/FAQs", @"Contact Us"]
#define SAVING_ARRAY @[@"Save a Copy (Duplicate)", @"Save to Photos App", @"Save to Evernote", @"Save to Google Drive"]
#define SHARING_ARRAY @[@"Share on Facebook", @"Share on Twitter", @"Upload to Online Gallery", @"Send in Email", @"Send in iMessage/MMS"]

#define kMenuHeaderHeight 30
#define kMenuCellHeight 44
#define kMenuViewHeight kMenuCellHeight*([SAVING_ARRAY count]+[SHARING_ARRAY count]+[MENU_ARRAY count]-4)+kMenuHeaderHeight*3

@protocol WBMenuContentViewDelegate
- (void)saveACopy;
- (void)shareOnFacebook;

@required
- (UIImage *)image;
- (void)doneEditing;
@end

@interface WBMenuContentView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)animateUp;
- (void)animateDown;
- (void)addMenuItem:(WBMenuItem *)item;
- (void)removeAllMenuItems;

@property (nonatomic, assign) id<WBMenuContentViewDelegate> delegate;

@end
