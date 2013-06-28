//
//  TextElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "TextElement.h"
#import "PlaceHolderTextView.h"
#import "SettingManager.h"
#import "UIColor+GSString.h"
#import "KxMenu.h"
#import "HistoryManager.h"
#import "HistoryElementTextChanged.h"

@interface TextElement() {
    PlaceHolderTextView *placeHolderTextView;
    NSString *oldFontName;
    int oldFontSize;
    UIColor *oldColor;
    float oldColorX;
    float oldColorY;
    NSString *oldText;
}
@end

@implementation TextElement
@synthesize myFontName = _myFontName;
@synthesize myFontSize = _myFontSize;
@synthesize myColor = _myColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlaceHolderWithFrame:frame];
        
        [self updateWithFontName:[[SettingManager sharedManager] currentFontName]
                            size:[[SettingManager sharedManager] currentFontSize]];
        [self updateWithColor:[[SettingManager sharedManager] getCurrentColorTab].tabColor x:-50 y:-50];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)initPlaceHolderWithFrame:(CGRect)frame {
    placeHolderTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [placeHolderTextView setBackgroundColor:[UIColor clearColor]];
    [placeHolderTextView setTextColor:[UIColor darkGrayColor]];
    [placeHolderTextView setFont:[UIFont systemFontOfSize:17.0f]];
    [placeHolderTextView setDelegate:self];
    [placeHolderTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [placeHolderTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [self addSubview:placeHolderTextView];
}

- (void)setText:(NSString *)text {
    [((PlaceHolderTextView *)[self contentView]) setText:text];
    [((PlaceHolderTextView *)[self contentView]) textChanged];
}

- (UIView *)contentView {
    return placeHolderTextView;
}

- (void)restore {
    self.transform = self.defaultTransform;
    placeHolderTextView.frame = CGRectMake(placeHolderTextView.frame.origin.x,
                                           placeHolderTextView.frame.origin.y,
                                           placeHolderTextView.contentSize.width,
                                           placeHolderTextView.contentSize.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.transform = self.currentTransform;
}

- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize {
    self.myFontName = fontName;
    if (fontSize > 0) self.myFontSize = fontSize;
    [placeHolderTextView setFont:[UIFont fontWithName:fontName size:self.myFontSize]];
    [self restore];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdateFont" object:self userInfo:@{@"fontName": self.myFontName, @"fontSize": [NSNumber numberWithInt:self.myFontSize]}];
}

- (void)updateWithFontName:(NSString *)fontName {
    [self updateWithFontName:fontName size:-1];
}

- (void)updateWithColor:(UIColor *)color x:(float)x y:(float)y {
    self.myColor = color;
    self.myColorLocX = x;
    self.myColorLocY = y;
    [placeHolderTextView setTextColor:color];
}

- (void)updateWithColor:(UIColor *)color {
    self.myColor = color;
    [placeHolderTextView setTextColor:color];
}

- (void)checkHistory {
    oldFontName = self.myFontName;
    oldFontSize = self.myFontSize;
    
    oldColor = self.myColor;
    oldColorX = self.myColorLocX;
    oldColorY = self.myColorLocY;
    
    oldText = [[NSString alloc] initWithString:[((UITextView *)[self contentView]) text]];
}

#pragma mark - Place Holder Text View Delegate
- (void)revive {
    [self checkHistory];
    [super revive];
    if (![placeHolderTextView isFirstResponder]) {
        [placeHolderTextView becomeFirstResponder];
    }
    [placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [placeHolderTextView revive];
}

- (void)rest {
    [super rest];
    if ([placeHolderTextView isFirstResponder]) {
        [placeHolderTextView resignFirstResponder];
    }
    [placeHolderTextView setPlaceHolderText:@""];
    [placeHolderTextView rest];
        
    if (self.elementCreated) {
        [[HistoryManager sharedManager] addActionTextContentChangedElement:self
                                                            withOriginText:oldText
                                                           withChangedText:((UITextView *)[self contentView]).text
                                                                   forPage:(WBPage *)self.superview
                                                                 withBlock:^(HistoryElementTextChanged *history, NSError *error) {
                                                                     if (history) {
                                                                         if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                             [self.delegate pageHistoryCreated:history];
                                                                         }
                                                                     }
                                                                 }];
        
        [[HistoryManager sharedManager] addActionTextFontChangedElement:self
                                                     withOriginFontName:oldFontName
                                                               fontSize:oldFontSize
                                                    withChangedFontName:self.myFontName
                                                               fontSize:self.myFontSize
                                                                forPage:(WBPage *)self.superview
                                                              withBlock:^(HistoryAction *history, NSError *error) {
                                                                  if (history) {
                                                                      if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                          [self.delegate pageHistoryCreated:history];
                                                                      }
                                                                  }
                                                              }];
        
        [[HistoryManager sharedManager] addActionTextColorChangedElement:self
                                                         withOriginColor:oldColor
                                                                       x:oldColorX
                                                                       y:oldColorY
                                                        withChangedColor:self.myColor
                                                                       x:self.myColorLocX
                                                                       y:self.myColorLocY
                                                                 forPage:(WBPage *)self.superview
                                                               withBlock:^(HistoryAction *history, NSError *error) {
                                                                   if (history) {
                                                                       if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                           [self.delegate pageHistoryCreated:history];
                                                                       }
                                                                   }
                                                               }];
    }
    self.elementCreated = YES;
    [self checkHistory];
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [self rest];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(element:hideKeyboard:)]) {
        [self.delegate element:self hideKeyboard:YES];
    }
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"TextElement" forKey:@"element_type"];
    [dict setObject:placeHolderTextView.text forKey:@"element_text"];
    [dict setObject:self.myFontName forKey:@"element_font_name"];
    [dict setObject:[NSNumber numberWithInt:self.myFontSize] forKey:@"element_font_size"];
    [dict setObject:[self.myColor gsString] forKey:@"element_font_color"];
    [dict setObject:[NSNumber numberWithFloat:self.myColorLocX] forKey:@"element_font_color_x"];
    [dict setObject:[NSNumber numberWithFloat:self.myColorLocY] forKey:@"element_font_color_y"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
    
    NSString *text = [elementData objectForKey:@"element_text"];
    [self setText:text];
    
    NSString *fontName = [elementData objectForKey:@"element_font_name"];
    int fontSize = [[elementData objectForKey:@"element_font_size"] intValue];
    [self updateWithFontName:fontName size:fontSize];
    
    UIColor *fontColor = [UIColor gsColorFromString:[elementData objectForKey:@"element_font_color"]];
    float fontColorX = [[elementData objectForKey:@"element_font_color_x"] floatValue];
    float fontColorY = [[elementData objectForKey:@"element_font_color_y"] floatValue];
    [self updateWithColor:fontColor x:fontColorX y:fontColorY];
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    placeHolderTextView = nil;
    self.myFontName = nil;
    self.myColor = nil;
}

@end
