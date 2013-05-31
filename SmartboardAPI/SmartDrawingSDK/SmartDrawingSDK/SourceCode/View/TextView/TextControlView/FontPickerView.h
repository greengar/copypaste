//
//  FontPickerView.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextView.h"

@interface FontPickerView : UIView <UIPickerViewDelegate>

@property (nonatomic, assign) TextView *currentTextView;

@end
