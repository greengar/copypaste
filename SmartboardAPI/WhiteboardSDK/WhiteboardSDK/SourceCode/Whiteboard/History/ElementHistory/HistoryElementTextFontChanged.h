//
//  HistoryElementTextFontChanged.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/7/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "HistoryElement.h"

@interface HistoryElementTextFontChanged : HistoryElement

@property (nonatomic, strong) NSString *originalFontName;
@property (nonatomic) int originalFontSize;
@property (nonatomic, strong) NSString *changedFontName;
@property (nonatomic) int changedFontSize;

@end
