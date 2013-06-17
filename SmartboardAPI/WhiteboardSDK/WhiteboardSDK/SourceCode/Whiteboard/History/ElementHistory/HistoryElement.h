//
//  HistoryElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryAction.h"
#import "WBBaseElement.h"
#import "TextElement.h"
#import "GLCanvasElement.h"
#import "CGCanvasElement.h"
#import "ImageElement.h"
#import "BackgroundElement.h"

@interface HistoryElement : HistoryAction

@property (nonatomic, strong) WBBaseElement *element;

@end
