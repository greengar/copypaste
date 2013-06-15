//
//  WBPage.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBBaseElement.h"
#import "GLCanvasElement.h"
#import "CGCanvasElement.h"
#import "FontPickerView.h"
#import "FontColorPickerView.h"
#import "ColorTabView.h"
#import "ColorPickerView.h"

@class WBPage;

@protocol WBPageDelegate
@optional
- (void)showExportControl:(WBPage *)page;
- (void)pageSelected:(WBPage *)page;
- (void)doneEditingPage:(WBPage *)page;
- (void)elementSelected:(WBBaseElement *)element;
- (void)elementDeselected:(WBBaseElement *)element;
@end

@interface WBPage : UIView <UIScrollViewDelegate, UIAlertViewDelegate, WBBaseViewDelegate>

- (id)initWithDict:(NSDictionary *)dictionary;
- (void)select;
- (UIImage *)exportPageToImage;
- (NSDictionary *)saveToDict;
+ (WBPage *)loadFromDict:(NSDictionary *)dict;

- (void)addElement:(WBBaseElement *)element;
- (void)removeElement:(WBBaseElement *)element;

- (void)focusOnTopElement;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic) BOOL isLocked;
@property (nonatomic, strong) WBBaseElement *selectedElementView;
@property (nonatomic, assign) id<WBPageDelegate> pageDelegate;

@end
