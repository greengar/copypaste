//
//  MySlider.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/25/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//
//  via http://mpatric.blogspot.com/2009/04/more-responsive-sliders-on-iphone.html
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomSlider : UISlider

- (void)setMinimumTitle:(NSString *)minTitle;
- (void)setMaximumTitle:(NSString *)maxTitle;

@end
