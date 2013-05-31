//
//  PlaceHolderTextView.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderTextView : UITextView <UITextInput>

- (void)setPlaceHolderText:(NSString *)placeHolderText;
- (void)updateFrame;

@end
