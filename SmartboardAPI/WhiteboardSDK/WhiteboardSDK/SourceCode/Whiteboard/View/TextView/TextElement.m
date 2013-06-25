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

@interface TextElement()
@property (nonatomic, strong) PlaceHolderTextView *placeHolderTextView;

// For History Font
@property (nonatomic, strong) NSString *oldFontName;
@property (nonatomic) int oldFontSize;

// For History Color
@property (nonatomic, strong) UIColor *oldColor;
@property (nonatomic) float oldColorX;
@property (nonatomic) float oldColorY;

// For History Content
@property (nonatomic, strong) NSString *oldText;

@end

@implementation TextElement
@synthesize placeHolderTextView = _placeHolderTextView;
@synthesize myFontName = _myFontName;
@synthesize myFontSize = _myFontSize;
@synthesize myColor = _myColor;
@synthesize oldFontName = _oldFontName;
@synthesize oldFontSize = _oldFontSize;
@synthesize oldColor = _oldColor;
@synthesize oldColorX = _oldColorX;
@synthesize oldColorY = _oldColorY;
@synthesize oldText = _oldText;

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
    self.placeHolderTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.placeHolderTextView setBackgroundColor:[UIColor clearColor]];
    [self.placeHolderTextView setTextColor:[UIColor darkGrayColor]];
    [self.placeHolderTextView setFont:[UIFont systemFontOfSize:17.0f]];
    [self.placeHolderTextView setDelegate:self];
    [self.placeHolderTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.placeHolderTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [self addSubview:self.placeHolderTextView];
}

- (void)setText:(NSString *)text {
    [((PlaceHolderTextView *)[self contentView]) setText:text];
    [((PlaceHolderTextView *)[self contentView]) textChanged];
}

- (UIView *)contentView {
    return self.placeHolderTextView;
}

- (void)restore {
    self.transform = self.defaultTransform;
    self.placeHolderTextView.frame = CGRectMake(self.placeHolderTextView.frame.origin.x,
                                                self.placeHolderTextView.frame.origin.y,
                                                self.placeHolderTextView.contentSize.width,
                                                self.placeHolderTextView.contentSize.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.transform = self.currentTransform;
}

- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize {
    self.myFontName = fontName;
    if (fontSize > 0) self.myFontSize = fontSize;
    [self.placeHolderTextView setFont:[UIFont fontWithName:fontName size:self.myFontSize]];
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
    [self.placeHolderTextView setTextColor:color];
}

- (void)updateWithColor:(UIColor *)color {
    self.myColor = color;
    [self.placeHolderTextView setTextColor:color];
}

- (void)checkHistory {
    self.oldFontName = self.myFontName;
    self.oldFontSize = self.myFontSize;
    
    self.oldColor = self.myColor;
    self.oldColorX = self.myColorLocX;
    self.oldColorY = self.myColorLocY;
    
    self.oldText = [((UITextView *)[self contentView]) text];
}

#pragma mark - Place Holder Text View Delegate
- (void)revive {
    [super revive];
    [[self contentView] becomeFirstResponder];
    [self.placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [self.placeHolderTextView revive];
    [self checkHistory];
}

- (void)rest {
    [super rest];
    [[self contentView] resignFirstResponder];
    [self.placeHolderTextView setPlaceHolderText:@""];
    [self.placeHolderTextView rest];
        
    if (self.elementCreated) {
        [[HistoryManager sharedManager] addActionTextFontChangedElement:self
                                                     withOriginFontName:self.oldFontName
                                                               fontSize:self.oldFontSize
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
                                                         withOriginColor:self.oldColor
                                                                       x:self.oldColorX
                                                                       y:self.oldColorY
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
        
        [[HistoryManager sharedManager] addActionTextContentChangedElement:self
                                                            withOriginText:self.oldText
                                                           withChangedText:((UITextView *)[self contentView]).text
                                                                   forPage:(WBPage *)self.superview
                                                                 withBlock:^(HistoryElementTextChanged *history, NSError *error) {
                                                                     if (history) {
                                                                         if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                                             [self.delegate pageHistoryCreated:history];
                                                                         }
                                                                     }
                                                                 }];
    }
    
    [self checkHistory];
    self.elementCreated = YES;

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
    [dict setObject:self.placeHolderTextView.text forKey:@"element_text"];
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

@end
