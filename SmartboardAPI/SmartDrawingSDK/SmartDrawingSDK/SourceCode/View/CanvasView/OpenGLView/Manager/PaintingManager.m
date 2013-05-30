//
//  PaintingManager.m
// SmartDrawingSDK
//
//  Created on 7/13/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "PaintingManager.h"
#import "SDUtils.h"

@implementation PaintingManager

+ (PaintingManager *)sharedManager { 
    static PaintingManager *sharedManager; 
    static dispatch_once_t done; 
    dispatch_once(&done, ^{ sharedManager = [PaintingManager new]; }); 
    return sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        me = [[Painting alloc] init];
        if(IS_IPAD) {
            [me updateDevice:iPadDevice];
            [me updateSize:768 and:1024];
        } else if (IS_IPHONE5) {
            [me updateDevice:iPhone5Device];
            [me updateSize:320 and:568];
        } else {
            [me updateDevice:iPhoneDevice];
            [me updateSize:320 and:480];
        }
        external = [[Painting alloc] init];
        
        if(IS_IPAD) {
            [external updateDevice:iPadDevice];
        } else if (IS_IPHONE5) {
            [external updateDevice:iPhone5Device];
        } else {
            [external updateDevice:iPhoneDevice];
        }
        collaborator = [[Painting alloc] init];
        current = nil;
        _callbacks = (NSMutableSet <PaintingManagerDelegate> *)[[NSMutableSet alloc] init];
    }
    return self;
}

- (void)registerCallback:(id)callback {
    if(!_callbacks) {
        _callbacks = (NSMutableSet <PaintingManagerDelegate> *)[[NSMutableSet alloc] init];
    }
    if(callback) {
        [_callbacks addObject:callback];
    }
}

- (void)removeCallback:(id)callback {
    if(!_callbacks) {
        _callbacks = (NSMutableSet <PaintingManagerDelegate> *)[[NSMutableSet alloc] init];
    }
    if(callback) {
        [_callbacks removeObject:callback];
    }        
}

- (Painting*) getPainting:(id)whiteboard {
    Painting *p = nil;
    if(whiteboard) {
        if([whiteboard isEqual:kCollaborator])
            p = collaborator;
        else
        {
            DLog(@"kExternal is requested");
            p = external;
        }
    } else {
        // nil for self
        p = me;
    }
    
    if(!p) {
        p = me;
    }
    
    return p;
}

- (void)updateColor:(CGColorRef)color of:(id)whiteboard {
    current = [self getPainting:whiteboard];
    if(color) {
        [current updateColor:color];
    }
    CGFloat* newColor = [current getColor];
    BOOL is = [current isEqual:me];
    for (id callback in _callbacks) {
        if([callback respondsToSelector:@selector(colorChanged:isSelf:)]) {
            id <PaintingManagerDelegate> c = callback;
            [c colorChanged:newColor isSelf:is];
        }
    }
}

- (void)updateOpacity:(CGFloat)opacity of:(id)whiteboard {
    current = [self getPainting:whiteboard];
    if(opacity >= 0) {
        [current updateOpacity:opacity];
    }
    CGFloat* newColor = [current getColor];
    BOOL is = [current isEqual:me];
    for (id callback in _callbacks) {
        if([callback respondsToSelector:@selector(colorChanged:isSelf:)]) {
            id <PaintingManagerDelegate> c = callback;
            [c colorChanged:newColor isSelf:is];
        }
    }
}
- (void)updatePointSize:(CGFloat)pointSize of:(id)whiteboard {
    current = [self getPainting:whiteboard];
    if(pointSize > 0) {
        [current updatePointSize:pointSize];
    }
    for (id callback in _callbacks) {
        if ([callback respondsToSelector:@selector(pointSizeChanged:isSelf:)]) {
            id <PaintingManagerDelegate> c = callback;
            [c pointSizeChanged:[current getPointSize] isSelf:([current isEqual:me])];
        }
    }
}

- (void)updateDevice:(GSDevice)inDevice of:(id)whiteboard {
    current = [self getPainting:whiteboard];
    if(inDevice) {
        [current updateDevice:inDevice];
    }
}

- (void) dealloc {
    if(me) {
        me = nil;
    }
    if(collaborator) {
        collaborator = nil;
    }
    if(_callbacks) {
        _callbacks = nil;
    }
}

- (CGFloat *)getColorOf:(id)whiteboard {
    return [[self getPainting:whiteboard] getColor];
}

- (CGFloat)getPointSizeOf:(id)whiteboard {
    return [[self getPainting:whiteboard] getPointSize];
}

- (GSDevice)getDeviceOf:(id)whiteboard {
    return [[self getPainting:whiteboard] getDevice];
}

- (CGFloat *)getColor {
    return [current getColor];
}

- (CGFloat)getPointSize {
    return [current getPointSize];
}

@end
