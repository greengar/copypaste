//
//  TabWrapperView.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 7/19/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSColorCircle.h"

@interface TabWrapperView : NSObject {
    GSColorCircle   *displayView;
    UIButton        *eventView;
}

- (id)initWithFrame:(CGRect)frame;
- (id)init;

@property (nonatomic, retain) GSColorCircle *displayView;
@property (nonatomic, retain) UIButton      *eventView;
@property (nonatomic) BOOL selected;

@end
