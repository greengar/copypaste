//
//  HistoryElementTextChanged.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"

@interface HistoryElementTextChanged : HistoryElement

@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *changedText;

@end
