//
//  HistoryElementTransform.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"

@interface HistoryElementTransform : HistoryElement

@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic) CGAffineTransform changedTransform;
@property (nonatomic) BOOL isFinished;

@end
