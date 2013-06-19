//
//  PlaceHolderTextView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"

#define kTextViewMaxWidth (IS_IPAD ? 768 : 320)

@interface PlaceHolderTextView : UITextView <UITextInput>
- (void)setPlaceHolderText:(NSString *)placeHolderText;
- (void)textChanged;
- (void)select;
- (void)deselect;
@end
