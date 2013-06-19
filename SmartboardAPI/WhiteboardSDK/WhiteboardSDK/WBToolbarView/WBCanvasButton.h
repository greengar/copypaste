//
//  WBCanvasButton.h
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBButton.h"

#define kCanvasButtonWidth 79

typedef enum {
    kCanvasMode = 0,
    kEraserMode,
    kTextMode
} CanvasMode;

@interface WBCanvasButton : WBButton

@property (nonatomic) CanvasMode mode;

@end
