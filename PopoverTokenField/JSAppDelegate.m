//
//  JSAppDelegate.m
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import "JSAppDelegate.h"
#import "JSTokenField.h"

@implementation JSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)LogButtonPressed:(id)sender {
    NSLog(@"%@",[self.window firstResponder]);
}

- (NSArray *)tokenField:(JSTokenField *)tokenField tokensGivenCurrentTokens:(NSArray *)tokens
{
    return [[NSArray alloc] initWithObjects:@"cat", @"dog", @"cow", @"fish", @"possum", @"kangaroo", @"bear", @"bee", @"lion", @"puma", @"turtle", @"panda", @"fly", @"horse", @"duck", nil];
}
    
@end
