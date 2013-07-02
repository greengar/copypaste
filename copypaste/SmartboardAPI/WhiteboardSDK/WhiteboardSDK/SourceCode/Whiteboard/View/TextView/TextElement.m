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
        [self checkHistory];
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

- (UIView *)contentDrawingView {
    return nil;
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

- (void)updateWithFontSize:(int)fontSize {
    [self updateWithFontName:self.myFontName size:fontSize];
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
    [super revive];
    [self checkHistory];
    [placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [placeHolderTextView revive];
    if (![placeHolderTextView isFirstResponder]) {
        [placeHolderTextView becomeFirstResponder];
    }
}

- (void)rest {
    [super rest];
    [placeHolderTextView setPlaceHolderText:@""];
    [placeHolderTextView rest];
    if ([placeHolderTextView isFirstResponder]) {
        [placeHolderTextView resignFirstResponder];
    }
        
    [[HistoryManager sharedManager] addActionTextContentChangedElement:self
                                                        withOriginText:oldText
                                                       withChangedText:((UITextView *)[self contentView]).text
                                                               forPage:(WBPage *)self.superview
                                                             withBlock:^(TextElement *element, NSError *error) {
        if (element) {
            oldText = ((UITextView *)[self contentView]).text;
            [self.delegate didChangeTextContent:((UITextView *)element.contentView).text
                                     elementUid:element.uid];
            }
        }];
    
    [[HistoryManager sharedManager] addActionTextFontChangedElement:self
                                                 withOriginFontName:oldFontName
                                                           fontSize:oldFontSize
                                                withChangedFontName:self.myFontName
                                                           fontSize:self.myFontSize
                                                            forPage:(WBPage *)self.superview
                                                          withBlock:^(TextElement *element, NSError *error) {
        if (element) {
            oldFontName = self.myFontName;
            oldFontSize = self.myFontSize;
            [self.delegate didChangeTextFont:element.myFontName
                                  elementUid:element.uid];
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
                                                           withBlock:^(TextElement *element, NSError *error) {
           if (element) {
               oldColor = self.myColor;
               [self.delegate didChangeTextColor:element.myColor
                                      elementUid:element.uid];
           }
       }];
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    [self checkHistory];
    self.isAlive = YES;
    [self.delegate element:self hideKeyboard:NO];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [self rest];
    [self stay];
    [self.delegate element:self hideKeyboard:YES];
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

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end