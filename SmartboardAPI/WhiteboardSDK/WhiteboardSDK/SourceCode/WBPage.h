//
//  SDPage.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBBaseElement.h"
#import "CanvasElement.h"
#import "FontPickerView.h"
#import "FontColorPickerView.h"
#import "ColorTabView.h"
#import "ColorPickerView.h"

@class WBPage;

@protocol SDPageDelegate
@optional
- (void)pageSelected:(WBPage *)page;
- (void)doneEditingPage:(WBPage *)page;
@end

@interface WBPage : UIView <UIScrollViewDelegate, UIAlertViewDelegate, WBBaseViewDelegate, ColorTabViewDelegate, ColorPickerViewDelegate, MainPaintViewDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;
- (void)setBackgroundImage:(UIImage *)image;
- (void)select;
- (UIImage *)exportPageToImage;
- (NSDictionary *)saveToDict;
+ (WBPage *)loadFromDict:(NSDictionary *)dict;

- (void)addElement:(WBBaseElement *)element;
- (void)removeElement:(WBBaseElement *)element;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) WBBaseElement *selectedElementView;
@property (nonatomic, assign) id<SDPageDelegate> delegate;

@end
