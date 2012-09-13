//
//  JSMessageInterceptor.m
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 1/09/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import "JSMessageInterceptor.h"

@implementation JSMessageInterceptor
@synthesize middleMan;
@synthesize receiver;

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([middleMan respondsToSelector:aSelector]) { return middleMan; }
    if ([receiver respondsToSelector:aSelector]) { return receiver; }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([[middleMan superclass] instancesRespondToSelector:aSelector]) { return NO; }
    if ([middleMan respondsToSelector:aSelector]) { return YES; }
    if ([receiver respondsToSelector:aSelector]) { return YES; }
    return [super respondsToSelector:aSelector];
}

@end
