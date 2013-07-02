//
//  HistoryElementCanvasDraw.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"
#import "PaintingCmd.h"

@interface HistoryElementCanvasDraw : HistoryElement

@property (nonatomic, strong) PaintingCmd *paintingCommand;

@end
