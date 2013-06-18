//
//  TabWrapperView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 7/19/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorCircleView.h"

@interface TabWrapperView : NSObject {
    ColorCircleView   *displayView;
    UIButton        *eventView;
}

- (id)initWithFrame:(CGRect)frame;
- (id)init;

@property (nonatomic, retain) ColorCircleView *displayView;
@property (nonatomic, retain) UIButton      *eventView;
@property (nonatomic) BOOL selected;

@end
