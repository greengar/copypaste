//
//  NameGen.m
//  Whiteboard
//
//  Created by Elliot Lee on 7/1/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "NameGen.h"
#import "GSUtils.h"

// via http://stackoverflow.com/questions/10837423/pick-random-element-of-nsarray-in-objective-c/10837462#10837462
@interface NSArray (Random)

- (id)randomObject;

@end

@implementation NSArray (Random)

-(id)randomObject {
    uint32_t rnd = arc4random_uniform([self count]);
    return [self objectAtIndex:rnd];
}

@end

@implementation NameGen

+ (NSString *)name
{
    static NSArray *adjs;
    static NSArray *nouns;
    static NSMutableDictionary *used; // try not to return the same name more than once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adjs = @[@"Awesome", @"Incredible", @"Amazing", @"Fantastic", @"Great", @"Terrific", @"Astonishing", @"Cool", @"Beautiful", @"Inspiring", @"Awe-inspiring", @"Extraordinary", @"Grand", @"Impressive", @"Magnificent", @"Majestic", @"Mind-blowing", @"Striking", @"Terrific", @"Wonderful", @"Wondrous", @"Good", @"Better", @"Best", @"Fine", @"Excellent", @"Fabulous", @"Extravagant", @"Fabulous", @"First-class", @"Phenomenal", @"Prodigious", @"Rad", @"Remarkable", @"Spectacular", @"Stupendous", @"Super", @"Superb", @"Simple", @"Sensational", @"Mighty", @"Marvelous", @"Tremendous"];
        nouns = @[@"Drawing", @"Canvas", @"Document", @"Illustration", @"Presentation", @"Doodle", @"Design", @"Art", @"Sketch", @"Note", @"Graphic", @"Storyboard", @"Picture", @"Painting", @"Layout", @"Cartoon", @"Painting", @"Whiteboard", @"Work of Art", @"Artwork", @"Tracing", @"Chart", @"Description", @"Draft", @"Depiction", @"Etching", @"Outline", @"Writing"];
        used = [NSMutableDictionary new];
    });
    const NSUInteger tries = 5;
    NSString *name;
    for (int i = 0; i < tries; i++)
    {
        name = [NSString stringWithFormat:@"%@ %@", [adjs randomObject], [nouns randomObject]];
        if (used[name] == nil) {
            used[name] = [NSNumber numberWithBool:YES];
            break;
        }
        DLog(@"name was already used. trying again...");
    }
    return name;
}

@end
