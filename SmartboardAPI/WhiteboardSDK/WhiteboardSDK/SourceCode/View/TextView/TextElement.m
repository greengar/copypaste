//
//  TextElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "TextElement.h"
#import "PlaceHolderTextView.h"
#import "SettingManager.h"
#import "UIColor+GSString.h"
#import "KxMenu.h"
#import "HistoryManager.h"

@interface TextElement()
@property (nonatomic, strong) PlaceHolderTextView *placeHolderTextView;

// For History
@property (nonatomic) BOOL fontChanged;
@property (nonatomic, strong) NSString *oldFontName;
@property (nonatomic) int oldFontSize;

// For History
@property (nonatomic) BOOL colorChanged;
@property (nonatomic, strong) UIColor *oldColor;
@property (nonatomic) float oldColorX;
@property (nonatomic) float oldColorY;

@end

@implementation TextElement
@synthesize placeHolderTextView = _placeHolderTextView;
@synthesize myFontName = _myFontName;
@synthesize myFontSize = _myFontSize;
@synthesize myColor = _myColor;
@synthesize fontChanged = _fontChanged;
@synthesize oldFontName = _oldFontName;
@synthesize oldFontSize = _oldFontSize;
@synthesize colorChanged = _colorChanged;
@synthesize oldColor = _oldColor;
@synthesize oldColorX = _oldColorX;
@synthesize oldColorY = _oldColorY;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        [self initPlaceHolderWithFrame:self.defaultFrame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlaceHolderWithFrame:frame];
        
        [self updateWithFontName:[[SettingManager sharedManager] currentFontName]
                            size:[[SettingManager sharedManager] currentFontSize]];
        [self updateWithColor:[[SettingManager sharedManager] currentFontColor] x:-50 y:-50];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.delegate elementSelected:self];
    }
}

- (void)setText:(NSString *)text {
    [((UITextView *)[self contentView]) setText:text];
}

- (UIView *)contentView {
    return self.placeHolderTextView;
}

- (void)select {
    [super select];
    [self.placeHolderTextView updateFrame];
    [self.placeHolderTextView setPlaceHolderText:@"Enter Text"];
    [self.placeHolderTextView textChanged];
    
    self.fontChanged = NO;
    self.oldFontName = self.myFontName;
    self.oldFontSize = self.myFontSize;
    
    self.colorChanged = NO;
    self.oldColor = self.myColor;
    self.oldColorX = self.myColorLocX;
    self.oldColorY = self.myColorLocY;
}

- (void)deselect {
    [super deselect];
    [self.placeHolderTextView setPlaceHolderText:@""];
    [self.placeHolderTextView textChanged];
    
    if (self.fontChanged) {
        [[HistoryManager sharedManager] addActionTextFontChangedElement:self
                                                     withOriginFontName:self.oldFontName
                                                               fontSize:self.oldFontSize
                                                    withChangedFontName:self.myFontName
                                                               fontSize:self.myFontSize];
        self.fontChanged = NO;
    }
    
    if (self.colorChanged) {
        [[HistoryManager sharedManager] addActionTextColorChangedElement:self
                                                         withOriginColor:self.oldColor
                                                                       x:self.oldColorX
                                                                       y:self.oldColorY
                                                        withChangedColor:self.myColor
                                                                       x:self.myColorLocX
                                                                       y:self.myColorLocY];
        self.colorChanged = NO;
    }
}

- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize {
    self.fontChanged = YES;
    self.myFontName = fontName;
    self.myFontSize = fontSize;
    [self.placeHolderTextView setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.placeHolderTextView updateFrame];
}

- (void)updateWithColor:(UIColor *)color x:(float)x y:(float)y {
    self.colorChanged = YES;
    self.myColor = color;
    self.myColorLocX = x;
    self.myColorLocY = y;
    [self.placeHolderTextView setTextColor:color];
    [self.placeHolderTextView updateFrame];
}

- (void)showMenu {
    NSArray *menuItems = @[[KxMenuItem menuItem:@"Edit"
                                          image:nil
                                         target:self
                                         action:@selector(select)],
                           [KxMenuItem menuItem:@"Bring to front"
                                          image:nil
                                         target:self
                                         action:@selector(bringFront)],
                           [KxMenuItem menuItem:@"Delete"
                                          image:nil
                                         target:self
                                         action:@selector(delete)], ];
    [KxMenu showMenuInView:[self superview]
                  fromRect:self.frame
                 menuItems:menuItems];
}


#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"TextElement" forKey:@"element_type"];
    [dict setObject:self.placeHolderTextView.text forKey:@"element_text"];
    [dict setObject:self.myFontName forKey:@"element_font_name"];
    [dict setObject:[NSNumber numberWithInt:self.myFontSize] forKey:@"element_font_size"];
    [dict setObject:[self.myColor gsString] forKey:@"element_font_color"];
    [dict setObject:[NSNumber numberWithFloat:self.myColorLocX] forKey:@"element_font_color_x"];
    [dict setObject:[NSNumber numberWithFloat:self.myColorLocY] forKey:@"element_font_color_y"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    TextElement *textElement = [[TextElement alloc] initWithDict:dictionary];
        
    NSString *text = [dictionary objectForKey:@"element_text"];
    [textElement setText:text];
    
    NSString *fontName = [dictionary objectForKey:@"element_font_name"];
    int fontSize = [[dictionary objectForKey:@"element_font_size"] intValue];
    [textElement updateWithFontName:fontName size:fontSize];
    
    UIColor *fontColor = [UIColor gsColorFromString:[dictionary objectForKey:@"element_font_color"]];
    float fontColorX = [[dictionary objectForKey:@"element_font_color_x"] floatValue];
    float fontColorY = [[dictionary objectForKey:@"element_font_color_y"] floatValue];
    [textElement updateWithColor:fontColor x:fontColorX y:fontColorY];
    
    return textElement;
}

@end
