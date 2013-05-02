//
//  CPNavigationView.h
//  copypaste
//
//  Created by Hector Zhao on 5/2/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPNavigationDelegate
@optional
- (void)backButtonTapped;
- (void)doneButtonTapped;
@end

@interface CPNavigationView : UIView
- (id)initWithFrame:(CGRect)frame hasBack:(BOOL)back hasDone:(BOOL)done;
@property (nonatomic, weak) id<CPNavigationDelegate> delegate;

@end
